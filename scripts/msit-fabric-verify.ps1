# MSIT Fabric Integration Verification Script
# Verifies connectivity to cpestaginglake for MSIT Fabric environment
# Author: Alex Cognitive Architecture  
# Date: August 7, 2025

param(
    [Parameter(Mandatory=$false)]
    [string]$WorkspaceId = "1dfcfdc6-64ff-4338-8eec-2676ff0f5884",
    
    [Parameter(Mandatory=$false)]
    [string]$StorageAccount = "cpestaginglake"
)

# Color functions
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Info { param($Message) Write-Host "ℹ️ $Message" -ForegroundColor Cyan }
function Write-Warning { param($Message) Write-Host "⚠️ $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }
function Write-Header { param($Message) Write-Host "`n🔗 $Message" -ForegroundColor Magenta -BackgroundColor Black }

Write-Header "MSIT Fabric Integration Verification"
Write-Info "Workspace ID: $WorkspaceId"
Write-Info "Storage Account: $StorageAccount"
Write-Info "Environment: https://msit.powerbi.com.mcas.ms/"

# Step 1: Verify Azure authentication
Write-Header "Step 1: Azure Authentication Check"
try {
    $account = az account show --query "{subscription: name, user: user.name, tenant: tenantId}" -o json | ConvertFrom-Json
    Write-Success "Authenticated to Azure"
    Write-Info "User: $($account.user)"
    Write-Info "Subscription: $($account.subscription)"
    Write-Info "Tenant: $($account.tenant)"
} catch {
    Write-Error "Not authenticated to Azure. Please run 'az login'"
    exit 1
}

# Step 2: Check storage account access
Write-Header "Step 2: Storage Account Access Check"
try {
    $storageInfo = az storage account show --name $StorageAccount --resource-group "integration" --query "{name: name, location: location, sku: sku.name, allowBlobPublicAccess: allowBlobPublicAccess, allowSharedKeyAccess: allowSharedKeyAccess}" -o json | ConvertFrom-Json
    Write-Success "Storage account found: $($storageInfo.name)"
    Write-Info "Location: $($storageInfo.location)"
    Write-Info "SKU: $($storageInfo.sku)"
    Write-Info "Public Blob Access: $($storageInfo.allowBlobPublicAccess)"
    Write-Info "Shared Key Access: $($storageInfo.allowSharedKeyAccess)"
    
    if ($storageInfo.allowSharedKeyAccess -eq $false) {
        Write-Success "Enterprise security: Key-based access disabled ✓"
    }
} catch {
    Write-Error "Cannot access storage account $StorageAccount"
    Write-Info "Ensure you have proper permissions"
    exit 1
}

# Step 3: List containers 
Write-Header "Step 3: Storage Containers Check"
try {
    # Use Azure AD authentication for listing containers
    $containers = az storage container list --account-name $StorageAccount --auth-mode login --query "[].{name: name, properties: properties}" -o json | ConvertFrom-Json
    
    if ($containers.Count -gt 0) {
        Write-Success "Found $($containers.Count) containers:"
        foreach ($container in $containers) {
            Write-Info "  📁 $($container.name)"
        }
    } else {
        Write-Warning "No containers found or insufficient permissions"
    }
} catch {
    Write-Error "Cannot list containers. Checking permissions..."
    
    # Check current user permissions
    $userId = az ad signed-in-user show --query objectId -o tsv
    $assignments = az role assignment list --assignee $userId --scope "/subscriptions/f6ab5f6d-606a-4256-aba7-1feeeb53784f/resourceGroups/integration/providers/Microsoft.Storage/storageAccounts/$StorageAccount" --query "[].{role: roleDefinitionName, scope: scope}" -o json | ConvertFrom-Json
    
    if ($assignments.Count -gt 0) {
        Write-Info "Current permissions:"
        foreach ($assignment in $assignments) {
            Write-Info "  🎭 $($assignment.role)"
        }
    } else {
        Write-Warning "No storage permissions found for current user"
        Write-Info "Run the permission grant script:"
        Write-Info "  .\scripts\grant-fabric-storage-permissions.ps1 -Operation grant"
    }
}

# Step 4: Verify Fabric workspace access guidance
Write-Header "Step 4: Fabric Integration Next Steps"
Write-Info "To complete the integration:"
Write-Info "1. Navigate to: https://msit.powerbi.com.mcas.ms/"
Write-Info "2. Find workspace: Fishbowl_POC"
Write-Info "3. Create new Lakehouse"
Write-Info "4. Add shortcut to: https://$StorageAccount.dfs.core.windows.net/"
Write-Info "5. Use Azure AD authentication"

Write-Header "Integration Check Complete"
Write-Success "Ready to proceed with Fabric OneLake shortcuts"
Write-Info "Refer to MSIT-FABRIC-INTEGRATION-GUIDE.md for detailed steps"
