# Simplified Synapse-OneLake Integration Guide
# Connects cpestaginglake to Microsoft Fabric/OneLake
# Author: Alex Cognitive Architecture  
# Date: August 7, 2025

# Storage Account Details
$StorageAccount = "cpestaginglake"
$ResourceGroup = "integration" 
$SubscriptionId = "f6ab5f6d-606a-4256-aba7-1feeeb53784f"

Write-Host "🔗 SYNAPSE-ONELAKE INTEGRATION SETUP" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta

# Step 1: Verify Storage Account Access
Write-Host "`n📋 STEP 1: Verify Storage Account Access" -ForegroundColor Cyan
Write-Host "Storage Account: $StorageAccount" -ForegroundColor Yellow
Write-Host "Resource Group: $ResourceGroup" -ForegroundColor Yellow

try {
    $storageDetails = az storage account show --name $StorageAccount --resource-group $ResourceGroup --query '{name:name, resourceGroup:resourceGroup, location:location, primaryEndpoints:primaryEndpoints}' -o json | ConvertFrom-Json
    Write-Host "✅ Storage account accessible" -ForegroundColor Green
    Write-Host "   Location: $($storageDetails.location)" -ForegroundColor Gray
    Write-Host "   Blob Endpoint: $($storageDetails.primaryEndpoints.blob)" -ForegroundColor Gray
    Write-Host "   Data Lake Endpoint: $($storageDetails.primaryEndpoints.dfs)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Cannot access storage account: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Get Storage Account Key
Write-Host "`n🔑 STEP 2: Retrieve Storage Account Access Key" -ForegroundColor Cyan
try {
    $storageKey = az storage account keys list --resource-group $ResourceGroup --account-name $StorageAccount --query '[0].value' -o tsv
    if ($storageKey) {
        Write-Host "✅ Storage access key retrieved" -ForegroundColor Green
        $keyPreview = $storageKey.Substring(0, 8) + "..." + $storageKey.Substring($storageKey.Length - 8)
        Write-Host "   Key Preview: $keyPreview" -ForegroundColor Gray
    } else {
        Write-Host "❌ Failed to retrieve storage key" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error retrieving storage key: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 3: List Storage Containers
Write-Host "`n📁 STEP 3: Discover Storage Containers" -ForegroundColor Cyan
try {
    $containers = az storage container list --account-name $StorageAccount --account-key $storageKey --query '[].{name:name, lastModified:properties.lastModified}' -o json | ConvertFrom-Json
    
    if ($containers.Count -gt 0) {
        Write-Host "✅ Found $($containers.Count) containers:" -ForegroundColor Green
        foreach ($container in $containers) {
            Write-Host "   📂 $($container.name)" -ForegroundColor Yellow
            if ($container.lastModified) {
                Write-Host "      Last Modified: $($container.lastModified)" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "⚠️ No containers found in storage account" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Error listing containers: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: Generate OneLake Connection Strings
Write-Host "`n🌊 STEP 4: Generate OneLake Connection Information" -ForegroundColor Cyan

$dfsEndpoint = $storageDetails.primaryEndpoints.dfs
$connectionString = "DefaultEndpointsProtocol=https;AccountName=$StorageAccount;AccountKey=$storageKey;EndpointSuffix=core.windows.net"

Write-Host "✅ Connection details generated:" -ForegroundColor Green
Write-Host "   DFS Endpoint: $dfsEndpoint" -ForegroundColor Yellow
Write-Host "   Connection String: AccountName=$StorageAccount;AccountKey=[KEY];..." -ForegroundColor Yellow

# Step 5: Create Integration Instructions
Write-Host "`n📝 STEP 5: Integration Instructions" -ForegroundColor Cyan

$instructions = @"

🎯 FABRIC WORKSPACE INTEGRATION STEPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

To connect your Synapse storage (cpestaginglake) to Microsoft Fabric:

1. 📱 OPEN FABRIC WORKSPACE
   • Navigate to: https://app.fabric.microsoft.com
   • Open your Fabric workspace (likely named similar to 'cxfabric')

2. 🏠 CREATE OR ACCESS LAKEHOUSE
   • Click '+ New' → 'Lakehouse' (if needed)
   • Or open existing lakehouse: 'FishbowlOneLake'

3. 🔗 CREATE SHORTCUTS TO SYNAPSE DATA
   For each container found above, create a shortcut:
   
   • In Lakehouse Explorer, right-click on 'Files'
   • Select 'New shortcut' → 'Azure Data Lake Storage Gen2'
   • Enter connection details:
     - URL: $dfsEndpoint
     - Container: [container-name]
     - Authentication: Account Key
     - Account Key: [Use the key retrieved above]

4. 📊 AVAILABLE CONTAINERS TO LINK:

"@

Write-Host $instructions -ForegroundColor White

# List each container with specific instructions
foreach ($container in $containers) {
    Write-Host "   📂 Container: $($container.name)" -ForegroundColor Yellow
    Write-Host "      Shortcut Path: Files/synapse-$($container.name)" -ForegroundColor Gray
    Write-Host "      Full URL: $dfsEndpoint$($container.name)" -ForegroundColor Gray
    Write-Host ""
}

# Step 6: PowerShell Commands for Automation
Write-Host "`n⚙️ STEP 6: PowerShell Automation (Optional)" -ForegroundColor Cyan

$automationScript = @"

# To automate this process, you can use these PowerShell commands:

# 1. Get Fabric API Token
`$token = az account get-access-token --resource https://api.fabric.microsoft.com --query accessToken -o tsv

# 2. Create shortcuts programmatically (requires workspace ID)
# Note: Replace 'WORKSPACE_ID' and 'LAKEHOUSE_ID' with actual values from Fabric portal

`$headers = @{'Authorization' = "Bearer `$token"; 'Content-Type' = 'application/json'}
`$workspaceId = "YOUR_WORKSPACE_ID"
`$lakehouseId = "YOUR_LAKEHOUSE_ID"

"@

foreach ($container in $containers) {
    $automationScript += @"

# Create shortcut for container: $($container.name)
`$payload = @{
    name = "synapse-$($container.name)"
    path = "Files/synapse-$($container.name)"
    target = @{
        adlsGen2 = @{
            url = "$dfsEndpoint"
            subpath = "/$($container.name)"
        }
    }
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "https://api.fabric.microsoft.com/v1/workspaces/`$workspaceId/items/`$lakehouseId/shortcuts" -Headers `$headers -Method POST -Body `$payload

"@
}

Write-Host $automationScript -ForegroundColor Gray

# Step 7: Next Steps
Write-Host "`n🚀 STEP 7: Next Steps After Integration" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$nextSteps = @"

1. 🔍 VERIFY DATA ACCESS
   • Browse to Files in your Lakehouse
   • Confirm you can see synapse-[container] folders
   • Preview data files to ensure connectivity

2. 📊 CREATE DELTA TABLES
   • Convert important datasets to Delta format
   • Use: CREATE TABLE AS SELECT FROM parquet/csv files
   • Enable time travel and ACID transactions

3. 🔧 BUILD DATA PIPELINES
   • Create Data Factory pipelines to process Synapse data
   • Schedule regular data refresh from source systems
   • Transform and enrich data for analytics

4. 📈 DEVELOP REPORTS
   • Connect Power BI to your Fabric lakehouse
   • Build dashboards using integrated Synapse data
   • Share insights across your organization

5. ⚡ ENABLE REAL-TIME ANALYTICS
   • Set up EventStreams for live data processing
   • Create real-time dashboards and alerts
   • Process streaming data alongside historical Synapse data

"@

Write-Host $nextSteps -ForegroundColor White

# Summary
Write-Host "`n✅ INTEGRATION SUMMARY" -ForegroundColor Green -BackgroundColor Black
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "✅ Storage Account: $StorageAccount verified and accessible" -ForegroundColor Green
Write-Host "✅ Access Key: Retrieved and ready for use" -ForegroundColor Green
Write-Host "✅ Containers: $($containers.Count) containers discovered" -ForegroundColor Green
Write-Host "✅ Connection Details: Generated for Fabric integration" -ForegroundColor Green
Write-Host "✅ Instructions: Complete manual and automated integration steps provided" -ForegroundColor Green

Write-Host "`n🎯 Your Synapse data is ready to be integrated with Microsoft Fabric!" -ForegroundColor Magenta
Write-Host "   Follow the manual steps above, or use the PowerShell automation commands." -ForegroundColor Yellow
Write-Host "   Once integrated, your ETL data will be accessible in the modern Fabric environment." -ForegroundColor Yellow

# Save connection details to file
Write-Host "`n💾 Saving connection details to synapse-fabric-connection.json..." -ForegroundColor Cyan

$connectionDetails = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    storageAccount = @{
        name = $StorageAccount
        resourceGroup = $ResourceGroup
        location = $storageDetails.location
        dfsEndpoint = $dfsEndpoint
        blobEndpoint = $storageDetails.primaryEndpoints.blob
    }
    containers = $containers
    integration = @{
        status = "ready"
        instructions = "Manual integration via Fabric portal or PowerShell automation"
        nextSteps = @(
            "Create shortcuts in Fabric Lakehouse",
            "Convert data to Delta format", 
            "Build analytics pipelines",
            "Create Power BI reports"
        )
    }
}

$connectionDetails | ConvertTo-Json -Depth 10 | Out-File -FilePath "synapse-fabric-connection.json" -Encoding UTF8
Write-Host "✅ Connection details saved to: synapse-fabric-connection.json" -ForegroundColor Green

Write-Host "`n🎉 Integration setup complete! Check the saved JSON file for reference." -ForegroundColor Magenta
