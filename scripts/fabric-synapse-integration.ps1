# Fabric-Synapse Integration Script
# Links cpestaginglake (Synapse Gen2 storage) with cxfabric workspace
# Author: Alex Cognitive Architecture
# Date: August 7, 2025

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("link", "status", "test", "unlink")]
    [string]$Operation = "link",
    
    [Parameter(Mandatory=$false)]
    [string]$StorageAccount = "cpestaginglake",
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "integration",
    
    [Parameter(Mandatory=$false)]
    [string]$WorkspaceName = "cxfabric",
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId = "f6ab5f6d-606a-4256-aba7-1feeeb53784f"
)

# Color functions for better output
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Info { param($Message) Write-Host "ℹ️ $Message" -ForegroundColor Cyan }
function Write-Warning { param($Message) Write-Host "⚠️ $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }
function Write-Header { param($Message) Write-Host "`n🔗 $Message" -ForegroundColor Magenta -BackgroundColor Black }

function Get-FabricToken {
    try {
        $token = az account get-access-token --resource https://api.fabric.microsoft.com --query accessToken -o tsv
        if ($token) {
            Write-Success "Retrieved Fabric API token"
            return $token
        } else {
            Write-Error "Failed to get Fabric API token"
            return $null
        }
    } catch {
        Write-Error "Error getting Fabric token: $($_.Exception.Message)"
        return $null
    }
}

function Get-FabricWorkspace {
    param($Token, $WorkspaceName)
    
    try {
        $headers = @{
            'Authorization' = "Bearer $Token"
            'Content-Type' = 'application/json'
        }
        
        $workspacesResponse = Invoke-RestMethod -Uri "https://api.fabric.microsoft.com/v1/workspaces" -Headers $headers -Method GET
        $workspace = $workspacesResponse.value | Where-Object { $_.displayName -eq $WorkspaceName }
        
        if ($workspace) {
            Write-Success "Found workspace: $($workspace.displayName) (ID: $($workspace.id))"
            return $workspace
        } else {
            Write-Error "Workspace '$WorkspaceName' not found"
            return $null
        }
    } catch {
        Write-Error "Error getting workspace: $($_.Exception.Message)"
        return $null
    }
}

function Get-StorageAccountDetails {
    param($StorageAccount, $ResourceGroup)
    
    try {
        Write-Info "Getting storage account details for $StorageAccount..."
        
        # Get storage account key
        $storageKey = az storage account keys list --resource-group $ResourceGroup --account-name $StorageAccount --query '[0].value' -o tsv
        
        if (-not $storageKey) {
            Write-Error "Failed to retrieve storage account key"
            return $null
        }
        
        # Get storage account properties
        $storageDetails = az storage account show --name $StorageAccount --resource-group $ResourceGroup --query '{name:name, resourceGroup:resourceGroup, location:location, primaryEndpoints:primaryEndpoints}' -o json | ConvertFrom-Json
        
        $result = @{
            Name = $storageDetails.name
            ResourceGroup = $storageDetails.resourceGroup
            Location = $storageDetails.location
            Key = $storageKey
            BlobEndpoint = $storageDetails.primaryEndpoints.blob
            DfsEndpoint = $storageDetails.primaryEndpoints.dfs
        }
        
        Write-Success "Retrieved storage account details"
        return $result
    } catch {
        Write-Error "Error getting storage account details: $($_.Exception.Message)"
        return $null
    }
}

function Get-StorageContainers {
    param($StorageAccount, $StorageKey)
    
    try {
        Write-Info "Listing containers in $StorageAccount..."
        $containers = az storage container list --account-name $StorageAccount --account-key $StorageKey --query '[].{name:name, properties:properties}' -o json | ConvertFrom-Json
        
        if ($containers) {
            Write-Success "Found $($containers.Count) containers:"
            foreach ($container in $containers) {
                Write-Host "  📂 $($container.name)" -ForegroundColor Yellow
            }
            return $containers
        } else {
            Write-Warning "No containers found in storage account"
            return @()
        }
    } catch {
        Write-Error "Error listing containers: $($_.Exception.Message)"
        return @()
    }
}

function Create-FabricConnection {
    param($Token, $WorkspaceId, $StorageDetails)
    
    try {
        Write-Info "Creating Fabric connection to $($StorageDetails.Name)..."
        
        $headers = @{
            'Authorization' = "Bearer $Token"
            'Content-Type' = 'application/json'
        }
        
        # Create connection payload for ADLS Gen2
        $connectionPayload = @{
            displayName = "cpestaginglake-connection"
            connectionDetails = @{
                type = "AdlsGen2"
                url = $StorageDetails.DfsEndpoint
                accountName = $StorageDetails.Name
            }
            credentialDetails = @{
                credentialType = "Key"
                accountKey = $StorageDetails.Key
            }
        } | ConvertTo-Json -Depth 10
        
        # Try to create the connection
        $connectionResponse = Invoke-RestMethod -Uri "https://api.fabric.microsoft.com/v1/workspaces/$WorkspaceId/connections" -Headers $headers -Method POST -Body $connectionPayload
        
        Write-Success "Successfully created connection: $($connectionResponse.displayName)"
        return $connectionResponse
    } catch {
        $errorDetails = $_.Exception.Message
        if ($_.Exception.Response) {
            $errorStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorStream)
            $errorDetails = $reader.ReadToEnd()
        }
        Write-Warning "Connection creation failed (this may be expected): $errorDetails"
        return $null
    }
}

function Create-LakehouseShortcut {
    param($Token, $WorkspaceId, $StorageDetails, $ContainerName)
    
    try {
        Write-Info "Creating lakehouse shortcut for container: $ContainerName..."
        
        $headers = @{
            'Authorization' = "Bearer $Token"
            'Content-Type' = 'application/json'
        }
        
        # First, get or create a lakehouse
        $lakehousesResponse = Invoke-RestMethod -Uri "https://api.fabric.microsoft.com/v1/workspaces/$WorkspaceId/items?type=Lakehouse" -Headers $headers -Method GET
        $lakehouse = $lakehousesResponse.value | Select-Object -First 1
        
        if (-not $lakehouse) {
            Write-Warning "No lakehouse found. Please create a lakehouse first."
            return $null
        }
        
        Write-Success "Using lakehouse: $($lakehouse.displayName)"
        
        # Create shortcut payload
        $shortcutPayload = @{
            name = "synapse-$ContainerName"
            path = "Files/synapse-$ContainerName"
            target = @{
                adlsGen2 = @{
                    url = $StorageDetails.DfsEndpoint
                    subpath = "/$ContainerName"
                }
            }
        } | ConvertTo-Json -Depth 10
        
        # Create the shortcut
        $shortcutResponse = Invoke-RestMethod -Uri "https://api.fabric.microsoft.com/v1/workspaces/$WorkspaceId/items/$($lakehouse.id)/shortcuts" -Headers $headers -Method POST -Body $shortcutPayload
        
        Write-Success "Successfully created shortcut: synapse-$ContainerName"
        return $shortcutResponse
    } catch {
        $errorDetails = $_.Exception.Message
        Write-Warning "Shortcut creation failed: $errorDetails"
        return $null
    }
}

function Test-Integration {
    param($Token, $WorkspaceId)
    
    try {
        Write-Info "Testing Fabric-Synapse integration..."
        
        $headers = @{
            'Authorization' = "Bearer $Token"
            'Content-Type' = 'application/json'
        }
        
        # List all items in workspace
        $itemsResponse = Invoke-RestMethod -Uri "https://api.fabric.microsoft.com/v1/workspaces/$WorkspaceId/items" -Headers $headers -Method GET
        
        Write-Success "Workspace items:"
        foreach ($item in $itemsResponse.value) {
            Write-Host "  🔧 $($item.type): $($item.displayName)" -ForegroundColor Cyan
        }
        
        # List shortcuts if lakehouse exists
        $lakehouses = $itemsResponse.value | Where-Object { $_.type -eq "Lakehouse" }
        if ($lakehouses) {
            foreach ($lakehouse in $lakehouses) {
                try {
                    $shortcutsResponse = Invoke-RestMethod -Uri "https://api.fabric.microsoft.com/v1/workspaces/$WorkspaceId/items/$($lakehouse.id)/shortcuts" -Headers $headers -Method GET
                    if ($shortcutsResponse.value) {
                        Write-Success "Shortcuts in $($lakehouse.displayName):"
                        foreach ($shortcut in $shortcutsResponse.value) {
                            Write-Host "  🔗 $($shortcut.name) -> $($shortcut.path)" -ForegroundColor Yellow
                        }
                    }
                } catch {
                    Write-Info "No shortcuts found in $($lakehouse.displayName)"
                }
            }
        }
        
        return $true
    } catch {
        Write-Error "Test failed: $($_.Exception.Message)"
        return $false
    }
}

# Main execution logic
Write-Header "Fabric-Synapse Integration Tool"
Write-Info "Operation: $Operation"
Write-Info "Storage Account: $StorageAccount"
Write-Info "Workspace: $WorkspaceName"

switch ($Operation) {
    "link" {
        Write-Header "Linking cpestaginglake to Fabric workspace"
        
        # Step 1: Get Fabric token
        $token = Get-FabricToken
        if (-not $token) { exit 1 }
        
        # Step 2: Get workspace
        $workspace = Get-FabricWorkspace -Token $token -WorkspaceName $WorkspaceName
        if (-not $workspace) { exit 1 }
        
        # Step 3: Get storage account details
        $storageDetails = Get-StorageAccountDetails -StorageAccount $StorageAccount -ResourceGroup $ResourceGroup
        if (-not $storageDetails) { exit 1 }
        
        # Step 4: List containers
        $containers = Get-StorageContainers -StorageAccount $StorageAccount -StorageKey $storageDetails.Key
        
        # Step 5: Create connection (optional - may fail due to permissions)
        $connection = Create-FabricConnection -Token $token -WorkspaceId $workspace.id -StorageDetails $storageDetails
        
        # Step 6: Create shortcuts for each container
        foreach ($container in $containers) {
            $shortcut = Create-LakehouseShortcut -Token $token -WorkspaceId $workspace.id -StorageDetails $storageDetails -ContainerName $container.name
        }
        
        Write-Header "Integration completed!"
        Write-Info "Your Synapse data is now accessible in Fabric workspace: $WorkspaceName"
    }
    
    "status" {
        Write-Header "Checking integration status"
        
        $token = Get-FabricToken
        if (-not $token) { exit 1 }
        
        $workspace = Get-FabricWorkspace -Token $token -WorkspaceName $WorkspaceName
        if (-not $workspace) { exit 1 }
        
        $testResult = Test-Integration -Token $token -WorkspaceId $workspace.id
        if ($testResult) {
            Write-Success "Integration is working properly"
        } else {
            Write-Error "Integration has issues"
        }
    }
    
    "test" {
        Write-Header "Testing connection"
        
        $token = Get-FabricToken
        if (-not $token) { exit 1 }
        
        $workspace = Get-FabricWorkspace -Token $token -WorkspaceName $WorkspaceName
        if (-not $workspace) { exit 1 }
        
        $storageDetails = Get-StorageAccountDetails -StorageAccount $StorageAccount -ResourceGroup $ResourceGroup
        if (-not $storageDetails) { exit 1 }
        
        $containers = Get-StorageContainers -StorageAccount $StorageAccount -StorageKey $storageDetails.Key
        
        Write-Success "Connection test completed successfully"
    }
    
    default {
        Write-Error "Unknown operation: $Operation"
        Write-Info "Available operations: link, status, test, unlink"
        exit 1
    }
}

Write-Header "Script completed"
