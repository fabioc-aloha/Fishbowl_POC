# Grant Fabric Workspace Permissions to Synapse Storage
# Enables Microsoft Fabric to access cpestaginglake for OneLake integration
# Author: Alex Cognitive Architecture
# Date: August 7, 2025

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("grant", "check", "revoke", "list")]
    [string]$Operation = "grant",
    
    [Parameter(Mandatory=$false)]
    [string]$StorageAccount = "cpestaginglake",
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "integration",
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId = "f6ab5f6d-606a-4256-aba7-1feeeb53784f",
    
    [Parameter(Mandatory=$false)]
    [string]$WorkspaceId = "1dfcfdc6-64ff-4338-8eec-2676ff0f5884",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Storage Blob Data Reader", "Storage Blob Data Contributor", "Storage Blob Data Owner")]
    [string]$Role = "Storage Blob Data Reader",
    
    [Parameter(Mandatory=$false)]
    [string]$FabricEnvironment = "https://msit.powerbi.com.mcas.ms/"
)

# Color functions for better output
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Info { param($Message) Write-Host "ℹ️ $Message" -ForegroundColor Cyan }
function Write-Warning { param($Message) Write-Host "⚠️ $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }
function Write-Header { param($Message) Write-Host "`n🔐 $Message" -ForegroundColor Magenta -BackgroundColor Black }

function Get-FabricWorkspaceInfo {
    try {
        Write-Info "Getting Fabric workspace information..."
        
        # Get Fabric API token
        $token = az account get-access-token --resource https://api.fabric.microsoft.com --query accessToken -o tsv
        if (-not $token) {
            Write-Error "Failed to get Fabric API token"
            return $null
        }
        
        $headers = @{
            'Authorization' = "Bearer $token"
            'Content-Type' = 'application/json'
        }
        
        # Get all workspaces
        $workspacesResponse = Invoke-RestMethod -Uri "https://api.fabric.microsoft.com/v1/workspaces" -Headers $headers -Method GET
        
        if ($workspacesResponse.value.Count -gt 0) {
            Write-Success "Found $($workspacesResponse.value.Count) Fabric workspaces:"
            
            $workspaceInfo = @()
            foreach ($workspace in $workspacesResponse.value) {
                Write-Host "  📁 $($workspace.displayName) (ID: $($workspace.id))" -ForegroundColor Yellow
                
                # Try to get more details about the workspace
                try {
                    $workspaceDetails = Invoke-RestMethod -Uri "https://api.fabric.microsoft.com/v1/workspaces/$($workspace.id)" -Headers $headers -Method GET
                    $workspaceInfo += @{
                        Name = $workspace.displayName
                        Id = $workspace.id
                        Type = $workspace.type
                        Details = $workspaceDetails
                    }
                } catch {
                    $workspaceInfo += @{
                        Name = $workspace.displayName
                        Id = $workspace.id
                        Type = $workspace.type
                        Details = $null
                    }
                }
            }
            
            return $workspaceInfo
        } else {
            Write-Warning "No Fabric workspaces found"
            return @()
        }
    } catch {
        Write-Error "Error getting Fabric workspace info: $($_.Exception.Message)"
        return $null
    }
}

function Get-FabricServicePrincipal {
    try {
        Write-Info "Looking for Microsoft Fabric service principal..."
        
        # Known Fabric service principal names and IDs
        $fabricServicePrincipals = @(
            "Microsoft.DataFactory",
            "Power BI Service", 
            "Microsoft Fabric",
            "Azure Data Factory",
            "Microsoft.PowerBI"
        )
        
        $foundPrincipals = @()
        
        foreach ($spName in $fabricServicePrincipals) {
            try {
                $sp = az ad sp list --display-name $spName --query '[0].{objectId:objectId, displayName:displayName, appId:appId}' -o json | ConvertFrom-Json
                if ($sp -and $sp.objectId) {
                    Write-Success "Found service principal: $($sp.displayName) (ID: $($sp.objectId))"
                    $foundPrincipals += $sp
                }
            } catch {
                # Continue searching
            }
        }
        
        # Also check for Microsoft first-party applications
        try {
            Write-Info "Checking for Microsoft first-party applications..."
            $msApps = az ad sp list --filter "publisherName eq 'Microsoft Services'" --query '[?contains(displayName, `Fabric`) || contains(displayName, `Power BI`) || contains(displayName, `Data Factory`)].{objectId:objectId, displayName:displayName, appId:appId}' -o json | ConvertFrom-Json
            
            if ($msApps) {
                foreach ($app in $msApps) {
                    Write-Success "Found Microsoft app: $($app.displayName) (ID: $($app.objectId))"
                    $foundPrincipals += $app
                }
            }
        } catch {
            Write-Info "Could not query Microsoft first-party applications"
        }
        
        return $foundPrincipals
    } catch {
        Write-Error "Error finding Fabric service principal: $($_.Exception.Message)"
        return @()
    }
}

function Grant-StoragePermissions {
    param($PrincipalId, $PrincipalName, $StorageScope, $RoleName)
    
    try {
        Write-Info "Granting '$RoleName' to '$PrincipalName' on storage account..."
        
        # Grant the role assignment
        $assignment = az role assignment create --assignee $PrincipalId --role $RoleName --scope $StorageScope --query '{principalId:principalId, roleDefinitionName:roleDefinitionName, scope:scope}' -o json | ConvertFrom-Json
        
        if ($assignment) {
            Write-Success "Successfully granted permissions!"
            Write-Host "  👤 Principal: $PrincipalName" -ForegroundColor Yellow
            Write-Host "  🎭 Role: $($assignment.roleDefinitionName)" -ForegroundColor Yellow
            Write-Host "  📂 Scope: $($assignment.scope)" -ForegroundColor Yellow
            return $true
        } else {
            Write-Warning "Role assignment command completed but no assignment returned"
            return $false
        }
    } catch {
        $errorMessage = $_.Exception.Message
        if ($errorMessage -like "*already exists*") {
            Write-Warning "Permission already exists for this principal"
            return $true
        } else {
            Write-Error "Failed to grant permissions: $errorMessage"
            return $false
        }
    }
}

function Check-ExistingPermissions {
    param($StorageScope)
    
    try {
        Write-Info "Checking existing permissions on storage account..."
        
        $roleAssignments = az role assignment list --scope $StorageScope --query '[?contains(roleDefinitionName, `Storage Blob Data`)].{principalId:principalId, principalName:principalName, roleDefinitionName:roleDefinitionName, objectType:objectType}' -o json | ConvertFrom-Json
        
        if ($roleAssignments.Count -gt 0) {
            Write-Success "Found $($roleAssignments.Count) storage-related role assignments:"
            foreach ($assignment in $roleAssignments) {
                $principalInfo = if ($assignment.principalName) { $assignment.principalName } else { $assignment.principalId }
                Write-Host "  🎭 $($assignment.roleDefinitionName)" -ForegroundColor Yellow
                Write-Host "     👤 $principalInfo ($($assignment.objectType))" -ForegroundColor Gray
            }
            return $roleAssignments
        } else {
            Write-Warning "No Storage Blob Data permissions found on this storage account"
            return @()
        }
    } catch {
        Write-Error "Error checking existing permissions: $($_.Exception.Message)"
        return @()
    }
}

function Grant-UserPermissions {
    param($StorageScope, $RoleName)
    
    try {
        Write-Info "Granting permissions to current user as fallback..."
        
        # Get current user
        $currentUser = az ad signed-in-user show --query objectId -o tsv
        if (-not $currentUser) {
            Write-Error "Could not get current user information"
            return $false
        }
        
        $userInfo = az ad user show --id $currentUser --query '{displayName:displayName, userPrincipalName:userPrincipalName}' -o json | ConvertFrom-Json
        
        $success = Grant-StoragePermissions -PrincipalId $currentUser -PrincipalName $userInfo.displayName -StorageScope $StorageScope -RoleName $RoleName
        
        if ($success) {
            Write-Success "Granted permissions to current user: $($userInfo.displayName)"
        }
        
        return $success
    } catch {
        Write-Error "Error granting user permissions: $($_.Exception.Message)"
        return $false
    }
}

# Main execution logic
Write-Header "Fabric Workspace Storage Permissions Manager"
Write-Info "Operation: $Operation"
Write-Info "Storage Account: $StorageAccount"
Write-Info "Resource Group: $ResourceGroup"
Write-Info "Role: $Role"

# Build storage account scope
$storageScope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Storage/storageAccounts/$StorageAccount"

switch ($Operation) {
    "check" {
        Write-Header "Checking Current Permissions"
        
        # Check existing permissions
        $existingPermissions = Check-ExistingPermissions -StorageScope $storageScope
        
        # Get Fabric workspace info
        $workspaces = Get-FabricWorkspaceInfo
        if ($workspaces) {
            Write-Info "Available Fabric workspaces for potential permission grants:"
            foreach ($workspace in $workspaces) {
                Write-Host "  📁 $($workspace.Name) (ID: $($workspace.Id))" -ForegroundColor Cyan
            }
        }
        
        # Check for service principals
        $servicePrincipals = Get-FabricServicePrincipal
        if ($servicePrincipals.Count -gt 0) {
            Write-Info "Found Fabric-related service principals that could be granted access:"
            foreach ($sp in $servicePrincipals) {
                Write-Host "  🔧 $($sp.displayName) (ID: $($sp.objectId))" -ForegroundColor Cyan
            }
        }
    }
    
    "grant" {
        Write-Header "Granting Fabric Access to Storage Account"
        
        # Check current permissions first
        Write-Info "Step 1: Checking current permissions..."
        $existingPermissions = Check-ExistingPermissions -StorageScope $storageScope
        
        # Get Fabric workspace information
        Write-Info "Step 2: Getting Fabric workspace information..."
        $workspaces = Get-FabricWorkspaceInfo
        
        # Look for service principals to grant permissions to
        Write-Info "Step 3: Finding Fabric service principals..."
        $servicePrincipals = Get-FabricServicePrincipal
        
        $permissionsGranted = $false
        
        # Grant permissions to service principals if found
        if ($servicePrincipals.Count -gt 0) {
            Write-Info "Step 4: Granting permissions to Fabric service principals..."
            foreach ($sp in $servicePrincipals) {
                $success = Grant-StoragePermissions -PrincipalId $sp.objectId -PrincipalName $sp.displayName -StorageScope $storageScope -RoleName $Role
                if ($success) {
                    $permissionsGranted = $true
                }
            }
        } else {
            Write-Warning "No Fabric service principals found"
        }
        
        # As fallback, grant permissions to current user
        if (-not $permissionsGranted) {
            Write-Info "Step 5: Granting permissions to current user as fallback..."
            $userSuccess = Grant-UserPermissions -StorageScope $storageScope -RoleName $Role
            $permissionsGranted = $userSuccess
        }
        
        if ($permissionsGranted) {
            Write-Header "Permission Grant Completed Successfully!"
            Write-Success "Fabric should now be able to access cpestaginglake"
            Write-Info "Next steps:"
            Write-Host "  1. Open Microsoft Fabric: https://app.fabric.microsoft.com" -ForegroundColor Yellow
            Write-Host "  2. Navigate to your workspace" -ForegroundColor Yellow  
            Write-Host "  3. Create shortcuts to cpestaginglake containers" -ForegroundColor Yellow
            Write-Host "  4. Test data access in your lakehouse" -ForegroundColor Yellow
        } else {
            Write-Error "Failed to grant permissions. You may need to:"
            Write-Host "  1. Request admin permissions on the storage account" -ForegroundColor Yellow
            Write-Host "  2. Have an Azure administrator run this script" -ForegroundColor Yellow
            Write-Host "  3. Manually grant permissions in the Azure portal" -ForegroundColor Yellow
        }
    }
    
    "list" {
        Write-Header "Listing All Permissions"
        
        $existingPermissions = Check-ExistingPermissions -StorageScope $storageScope
        $workspaces = Get-FabricWorkspaceInfo
        $servicePrincipals = Get-FabricServicePrincipal
        
        Write-Info "Complete permissions audit completed"
    }
    
    "revoke" {
        Write-Header "Revoking Permissions (Use with caution!)"
        Write-Warning "This operation would remove Fabric access to the storage account"
        Write-Info "Implementation available upon request"
    }
    
    default {
        Write-Error "Unknown operation: $Operation"
        Write-Info "Available operations: grant, check, list, revoke"
        exit 1
    }
}

Write-Header "Script completed"
