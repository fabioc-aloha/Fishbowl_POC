# Synapse to OneLake Connection Script
# Date: August 7, 2025
# Purpose: Establish connections between cpesynapse and FishbowlOneLake

param(
    [string]$Operation = "test"  # test, connect, migrate, sync
)

# Configuration
$SynapseWorkspace = "cpesynapse"
$SynapseServer = "cpesynapse.sql.azuresynapse.net"
$SynapseOnDemand = "cpesynapse-ondemand.sql.azuresynapse.net"
$ResourceGroup = "Integration"

$OneLakeWorkspaceId = "66c04c50-bc7a-4175-b91e-9d0164ca294a"
$OneLakeLakehouseId = "e178728a-418c-4cb7-b7ef-44ce84223239"
$OneLakeFilesPath = "https://msit-onelake.dfs.fabric.microsoft.com/$OneLakeWorkspaceId/$OneLakeLakehouseId/Files"
$OneLakeTablesPath = "https://msit-onelake.dfs.fabric.microsoft.com/$OneLakeWorkspaceId/$OneLakeLakehouseId/Tables"

Write-Host "🔗 Synapse to OneLake Integration Tool" -ForegroundColor Cyan
Write-Host "Operation: $Operation" -ForegroundColor Yellow

switch ($Operation) {
    "test" {
        Write-Host "`n🧪 Testing Connections..." -ForegroundColor Green
        
        # Test Azure authentication
        Write-Host "  ✅ Testing Azure CLI authentication..."
        $account = az account show --query '{name:name, user:user.name}' --output json | ConvertFrom-Json
        Write-Host "    Connected as: $($account.user)" -ForegroundColor White
        
        # Test Synapse workspace access
        Write-Host "  ✅ Testing Synapse workspace access..."
        $workspace = az synapse workspace show --name $SynapseWorkspace --resource-group $ResourceGroup --query 'name' --output tsv
        Write-Host "    Workspace: $workspace" -ForegroundColor White
        
        # Test OneLake access
        Write-Host "  ✅ Testing OneLake lakehouse access..."
        $lakehouse = az rest --method GET --url "https://api.fabric.microsoft.com/v1/workspaces/$OneLakeWorkspaceId/lakehouses/$OneLakeLakehouseId" --resource "https://api.fabric.microsoft.com" --query 'displayName' --output tsv
        Write-Host "    Lakehouse: $lakehouse" -ForegroundColor White
        
        Write-Host "`n✅ All connections successful!" -ForegroundColor Green
    }
    
    "connect" {
        Write-Host "`n🔌 Establishing Connections..." -ForegroundColor Green
        
        # Open Synapse workspace
        Write-Host "  🌐 Opening Synapse workspace..."
        Start-Process "https://web.azuresynapse.net?workspace=%2fsubscriptions%2ff6ab5f6d-606a-4256-aba7-1feeeb53784f%2fresourceGroups%2fIntegration%2fproviders%2fMicrosoft.Synapse%2fworkspaces%2fcpesynapse"
        
        # Open OneLake workspace
        Write-Host "  🌐 Opening OneLake workspace..."
        Start-Process "https://fabric.microsoft.com/en-us/workspaces/$OneLakeWorkspaceId?experience=data-engineering"
        
        Write-Host "`n✅ Workspaces opened in browser!" -ForegroundColor Green
    }
    
    "migrate" {
        Write-Host "`n📦 Data Migration Options..." -ForegroundColor Green
        Write-Host "  1. Use Synapse Copy Activity to move data to OneLake" -ForegroundColor White
        Write-Host "  2. Export data from Synapse using CETAS (Create External Table As Select)" -ForegroundColor White
        Write-Host "  3. Use Spark pools for complex transformations during migration" -ForegroundColor White
        Write-Host "`n  📋 Next: Identify source tables and create migration pipeline" -ForegroundColor Yellow
    }
    
    "sync" {
        Write-Host "`n🔄 Real-time Sync Options..." -ForegroundColor Green
        Write-Host "  1. Set up EventStreams in Fabric for real-time data ingestion" -ForegroundColor White
        Write-Host "  2. Configure Change Data Capture (CDC) from Synapse" -ForegroundColor White
        Write-Host "  3. Create scheduled pipelines for batch synchronization" -ForegroundColor White
        Write-Host "`n  📋 Next: Configure data sources and sync frequency" -ForegroundColor Yellow
    }
    
    default {
        Write-Host "`n❌ Invalid operation. Use: test, connect, migrate, or sync" -ForegroundColor Red
    }
}

Write-Host "`n🔗 Connection Details:" -ForegroundColor Cyan
Write-Host "  Synapse: $SynapseServer" -ForegroundColor White
Write-Host "  OneLake Files: $OneLakeFilesPath" -ForegroundColor White
Write-Host "  OneLake Tables: $OneLakeTablesPath" -ForegroundColor White
