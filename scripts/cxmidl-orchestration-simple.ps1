# CXMIDL Orchestration Database Integration - Simplified MFA Version
# Alex Taylor Finch Cognitive Architecture - Azure Enterprise Data Platform
# Version: 1.0.0 UNNILNILIUM

param(
    [Parameter()]
    [ValidateSet("test", "orchestration", "health")]
    [string]$Action = "test",
    
    [Parameter()]
    [switch]$UseMFA,
    
    [Parameter()]
    [switch]$Detailed
)

# Enterprise configuration - Orchestration Database Focus
$ServerName = "cxmidl.database.windows.net"
$DatabaseName = "Orchestration"
$IntegrationId = "cxmidl-orchestration-enterprise"

# Import required modules
try {
    Import-Module SqlServer -ErrorAction SilentlyContinue
    Import-Module Az.Accounts -ErrorAction SilentlyContinue
} catch {
    Write-Warning "Azure modules may not be installed. Use 'Install-Module Az' for full functionality."
}

function Write-IntegrationHeader {
    Write-Host "🏢 CXMIDL Orchestration Database Integration" -ForegroundColor Cyan
    Write-Host "Server: $ServerName" -ForegroundColor Green
    Write-Host "Database: $DatabaseName" -ForegroundColor Yellow
    Write-Host "Integration ID: $IntegrationId" -ForegroundColor Magenta
    Write-Host "MFA Mode: $(if($UseMFA) {'✅ Interactive'} else {'🔑 Azure CLI Token'})" -ForegroundColor $(if($UseMFA) {'Green'} else {'Yellow'})
    Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host "=" * 70 -ForegroundColor DarkCyan
    Write-Host ""
}

function Test-OrchestrationConnection {
    Write-Host "🔍 Testing connection to Orchestration database..." -ForegroundColor Yellow
    
    if ($UseMFA) {
        Write-Host "🔐 MFA authentication enabled - you may be prompted to sign in" -ForegroundColor Cyan
    } else {
        Write-Host "🔑 Using Azure CLI token authentication" -ForegroundColor Cyan
    }
    
    try {
        # Simple connectivity test
        $TestQuery = @"
SELECT 
    GETDATE() as CurrentTime,
    DB_NAME() as DatabaseName,
    SYSTEM_USER as CurrentUser,
    @@SERVERNAME as ServerName,
    @@SPID as SessionId
"@
        
        # Get access token
        $AccessToken = (Get-AzAccessToken -ResourceUrl "https://database.windows.net/").Token
        
        if (!$AccessToken) {
            throw "Failed to obtain Azure access token. Please run 'az login' first."
        }
        
        $Results = Invoke-Sqlcmd -ServerInstance $ServerName -Database $DatabaseName -Query $TestQuery -AccessToken $AccessToken -ErrorAction Stop
        
        Write-Host "✅ Successfully connected to Orchestration database!" -ForegroundColor Green
        Write-Host "  🕒 Current Time: $($Results.CurrentTime)" -ForegroundColor White
        Write-Host "  📊 Database: $($Results.DatabaseName)" -ForegroundColor White
        Write-Host "  👤 User: $($Results.CurrentUser)" -ForegroundColor Cyan
        Write-Host "  🖥️  Server: $($Results.ServerName)" -ForegroundColor White
        Write-Host "  📋 Session: $($Results.SessionId)" -ForegroundColor Gray
        
        return @{
            Status = "Success"
            Server = $Results.ServerName
            Database = $Results.DatabaseName
            CurrentUser = $Results.CurrentUser
            SessionId = $Results.SessionId
            Timestamp = $Results.CurrentTime
            IntegrationId = $IntegrationId
        }
        
    } catch {
        Write-Host "❌ Connection failed!" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        
        # Basic connectivity test
        try {
            Write-Host "🔄 Testing basic network connectivity..." -ForegroundColor Yellow
            $TestConnection = Test-NetConnection -ComputerName $ServerName -Port 1433 -WarningAction SilentlyContinue
            
            if ($TestConnection.TcpTestSucceeded) {
                Write-Host "✅ Server is reachable on port 1433" -ForegroundColor Green
                Write-Host "💡 Authentication issue - try running 'az login' or use -UseMFA" -ForegroundColor Yellow
            } else {
                Write-Host "❌ Cannot reach server on port 1433" -ForegroundColor Red
            }
        } catch {
            Write-Host "⚠️ Network test failed" -ForegroundColor Yellow
        }
        
        return @{
            Status = "Failed"
            Server = $ServerName
            Database = $DatabaseName
            Error = $_.Exception.Message
            Timestamp = Get-Date
        }
    }
}

function Get-OrchestrationAnalysis {
    Write-Host "🎼 Analyzing Orchestration database structure..." -ForegroundColor Yellow
    
    try {
        $AnalysisQuery = @"
-- Orchestration Database Structure Analysis
SELECT 
    'Database_Info' as AnalysisType,
    DB_NAME() as Value,
    'Current database name' as Description
    
UNION ALL

SELECT 
    'Table_Count',
    CAST(COUNT(*) as VARCHAR(10)) as Value,
    'Total user tables' as Description
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'

UNION ALL

SELECT 
    'View_Count',
    CAST(COUNT(*) as VARCHAR(10)) as Value,
    'Total views' as Description
FROM INFORMATION_SCHEMA.VIEWS

UNION ALL

SELECT 
    'Procedure_Count',
    CAST(COUNT(*) as VARCHAR(10)) as Value,
    'Total stored procedures' as Description
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_TYPE = 'PROCEDURE'

UNION ALL

SELECT 
    'Function_Count',
    CAST(COUNT(*) as VARCHAR(10)) as Value,
    'Total functions' as Description
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_TYPE = 'FUNCTION'

ORDER BY AnalysisType
"@
        
        $AccessToken = (Get-AzAccessToken -ResourceUrl "https://database.windows.net/").Token
        $AnalysisResults = Invoke-Sqlcmd -ServerInstance $ServerName -Database $DatabaseName -Query $AnalysisQuery -AccessToken $AccessToken -ErrorAction Stop
        
        Write-Host "✅ Orchestration database analysis completed:" -ForegroundColor Green
        
        foreach ($result in $AnalysisResults) {
            $emoji = switch ($result.AnalysisType) {
                'Database_Info' { '🎼' }
                'Table_Count' { '📋' }
                'View_Count' { '👁️' }
                'Procedure_Count' { '⚙️' }
                'Function_Count' { '🔧' }
                default { '📊' }
            }
            Write-Host "  $emoji $($result.AnalysisType.Replace('_', ' ')): $($result.Value)" -ForegroundColor White
            if ($Detailed) {
                Write-Host "    📝 $($result.Description)" -ForegroundColor Gray
            }
        }
        
        return $AnalysisResults
        
    } catch {
        Write-Host "❌ Database analysis failed!" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Get-OrchestrationTables {
    Write-Host "📋 Retrieving Orchestration table information..." -ForegroundColor Yellow
    
    try {
        $TablesQuery = @"
SELECT TOP 20
    s.name as SchemaName,
    t.name as TableName,
    CASE 
        WHEN t.name LIKE '%orchestr%' OR t.name LIKE '%workflow%' OR t.name LIKE '%job%' OR t.name LIKE '%task%' THEN 'Core_Orchestration'
        WHEN t.name LIKE '%log%' OR t.name LIKE '%audit%' OR t.name LIKE '%history%' THEN 'Logging_Audit'
        WHEN t.name LIKE '%config%' OR t.name LIKE '%setting%' OR t.name LIKE '%param%' THEN 'Configuration'
        ELSE 'General'
    END as TableCategory,
    (SELECT COUNT(*) FROM sys.columns c WHERE c.object_id = t.object_id) as ColumnCount
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
ORDER BY TableCategory, t.name
"@
        
        $AccessToken = (Get-AzAccessToken -ResourceUrl "https://database.windows.net/").Token
        $TablesResults = Invoke-Sqlcmd -ServerInstance $ServerName -Database $DatabaseName -Query $TablesQuery -AccessToken $AccessToken -ErrorAction Stop
        
        Write-Host "✅ Found $($TablesResults.Count) tables (showing top 20):" -ForegroundColor Green
        
        $CurrentCategory = ""
        foreach ($table in $TablesResults) {
            if ($table.TableCategory -ne $CurrentCategory) {
                $CurrentCategory = $table.TableCategory
                Write-Host "  📁 $($CurrentCategory.Replace('_', ' ')):" -ForegroundColor Cyan
            }
            Write-Host "    📊 $($table.SchemaName).$($table.TableName) ($($table.ColumnCount) columns)" -ForegroundColor White
        }
        
        return $TablesResults
        
    } catch {
        Write-Host "❌ Failed to retrieve table information!" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Main execution
Write-IntegrationHeader

$Results = @{}

switch ($Action.ToLower()) {
    "test" {
        $Results["Connection"] = Test-OrchestrationConnection
    }
    "orchestration" {
        $Results["Connection"] = Test-OrchestrationConnection
        if ($Results["Connection"].Status -eq "Success") {
            $Results["Analysis"] = Get-OrchestrationAnalysis
            $Results["Tables"] = Get-OrchestrationTables
        }
    }
    "health" {
        $Results["Connection"] = Test-OrchestrationConnection
        if ($Results["Connection"].Status -eq "Success") {
            $Results["Analysis"] = Get-OrchestrationAnalysis
        }
    }
    default {
        Write-Host "❌ Invalid action: $Action" -ForegroundColor Red
        Write-Host "Valid actions: test, orchestration, health" -ForegroundColor Yellow
        exit 1
    }
}

# Final summary
Write-Host ""
if ($Results["Connection"].Status -eq "Success") {
    Write-Host "🎯 Integration completed successfully!" -ForegroundColor Green
    Write-Host "✅ CXMIDL Orchestration database is accessible" -ForegroundColor Green
} else {
    Write-Host "⚠️ Integration completed with issues" -ForegroundColor Yellow
    Write-Host "❌ Connection to CXMIDL Orchestration database failed" -ForegroundColor Red
}

Write-Host "📊 Integration ID: $IntegrationId" -ForegroundColor Gray
Write-Host "🕒 Completed: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
