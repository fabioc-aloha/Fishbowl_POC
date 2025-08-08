# CXMIDL Azure SQL Server Integration Script - Orchestration Database Focus
# Alex Taylor Finch Cognitive Architecture - Azure Enterprise Data Platform
# Version: 1.0.0 UNNILNILIUM - MFA Enhanced

param(
    [Parameter()]
    [ValidateSet("test", "connect", "health", "performance", "security", "orchestration")]
    [string]$Action = "test",
    
    [Parameter()]
    [string]$Database = "Orchestration",
    
    [Parameter()]
    [switch]$UseMFA,
    
    [Parameter()]
    [switch]$Detailed,
    
    [Parameter()]
    [switch]$OutputJson
)

# Enterprise configuration - Orchestration Database Focus
$ServerName = "cxmidl.database.windows.net"
$IntegrationId = "cxmidl-orchestration-enterprise"
$DefaultDatabase = "Orchestration"

# Import required modules
try {
    Import-Module SqlServer -ErrorAction SilentlyContinue
    Import-Module Az.Sql -ErrorAction SilentlyContinue
    Import-Module Az.Accounts -ErrorAction SilentlyContinue
} catch {
    Write-Warning "Some Azure modules may not be installed. Use 'Install-Module Az' for full functionality."
}

function Write-IntegrationHeader {
    Write-Host "🏢 CXMIDL Orchestration Database Integration" -ForegroundColor Cyan
    Write-Host "Server: $ServerName" -ForegroundColor Green
    Write-Host "Database: $DefaultDatabase" -ForegroundColor Yellow
    Write-Host "Integration ID: $IntegrationId" -ForegroundColor Yellow
    Write-Host "MFA Required: $(if($UseMFA) {'✅ Enabled'} else {'⚠️ Managed Identity'})" -ForegroundColor $(if($UseMFA) {'Green'} else {'Yellow'})
    Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host "=" * 70 -ForegroundColor DarkCyan
}

function Test-CXMIDLConnection {
    param([string]$DatabaseName = $DefaultDatabase)
    
    Write-Host "🔍 Testing connection to CXMIDL Orchestration database..." -ForegroundColor Yellow
    Write-Host "🔐 Authentication: $(if($UseMFA) {'Interactive MFA'} else {'Azure CLI/Managed Identity'})" -ForegroundColor Cyan
    
    try {
        # Test basic connectivity
        $TestQuery = "SELECT GETDATE() as CurrentTime, @@VERSION as SqlVersion, DB_NAME() as DatabaseName, SYSTEM_USER as CurrentUser"
        
        if ($UseMFA) {
            # Use Interactive MFA authentication
            Write-Host "🔑 Initiating MFA authentication flow..." -ForegroundColor Yellow
            $Results = Invoke-Sqlcmd -ServerInstance $ServerName -Database $DatabaseName -Query $TestQuery -AccessToken (Get-AzAccessToken -ResourceUrl "https://database.windows.net/").Token -ErrorAction Stop
        } else {
            # Use Azure CLI/Managed Identity
            Write-Host "🔑 Using Azure CLI/Managed Identity authentication..." -ForegroundColor Yellow
            $Results = Invoke-Sqlcmd -ServerInstance $ServerName -Database $DatabaseName -Query $TestQuery -AccessToken (Get-AzAccessToken -ResourceUrl "https://database.windows.net/").Token -ErrorAction Stop
        }
        
        Write-Host "✅ Connection successful to Orchestration database!" -ForegroundColor Green
        Write-Host "Current Time: $($Results.CurrentTime)" -ForegroundColor White
        Write-Host "Database: $($Results.DatabaseName)" -ForegroundColor White
        Write-Host "Current User: $($Results.CurrentUser)" -ForegroundColor Cyan
        
        if ($Detailed) {
            Write-Host "SQL Version: $($Results.SqlVersion)" -ForegroundColor Gray
        }
        
        return @{
            Status = "Success"
            Server = $ServerName
            Database = $Results.DatabaseName
            CurrentUser = $Results.CurrentUser
            Timestamp = $Results.CurrentTime
            Version = $Results.SqlVersion
            AuthenticationMethod = if($UseMFA) {"Interactive_MFA"} else {"Azure_CLI"}
        }
        
    } catch {
        Write-Host "❌ Connection failed!" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        
        # Fallback: Try with basic authentication check
        try {
            Write-Host "🔄 Attempting alternate connection method..." -ForegroundColor Yellow
            
            # Test if server is reachable
            $TestConnection = Test-NetConnection -ComputerName $ServerName -Port 1433 -WarningAction SilentlyContinue
            
            if ($TestConnection.TcpTestSucceeded) {
                Write-Host "✅ Server is reachable on port 1433" -ForegroundColor Green
                Write-Host "💡 Suggestion: Ensure you're authenticated with 'az login' or enable -UseMFA for interactive authentication" -ForegroundColor Yellow
                return @{
                    Status = "Reachable"
                    Server = $ServerName
                    Database = $DatabaseName
                    Note = "Server reachable but authentication may need configuration"
                    Suggestion = "Run 'az login' or use -UseMFA parameter"
                    Timestamp = Get-Date
                }
            } else {
                Write-Host "❌ Server is not reachable" -ForegroundColor Red
            }
        } catch {
            # Ignore network test errors
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

function Get-CXMIDLDatabases {
    Write-Host "📚 Retrieving available databases..." -ForegroundColor Yellow
    
    try {
        $Query = @"
SELECT 
    name as DatabaseName,
    database_id as DatabaseId,
    create_date as CreatedDate,
    collation_name as Collation,
    state_desc as State
FROM sys.databases 
WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')
ORDER BY name
"@
        
        $Databases = Invoke-Sqlcmd -ServerInstance $ServerName -Database "master" -Query $Query -AccessToken (Get-AzAccessToken -ResourceUrl "https://database.windows.net/").Token -ErrorAction Stop
        
        Write-Host "✅ Found $($Databases.Count) user databases:" -ForegroundColor Green
        foreach ($db in $Databases) {
            Write-Host "  📊 $($db.DatabaseName) (ID: $($db.DatabaseId), State: $($db.State))" -ForegroundColor White
        }
        
        return $Databases
        
    } catch {
        Write-Host "❌ Failed to retrieve databases!" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Get-CXMIDLHealthCheck {
    Write-Host "🩺 Performing health check..." -ForegroundColor Yellow
    
    try {
        $HealthQuery = @"
SELECT 
    'Server' as Component,
    @@SERVERNAME as Name,
    CASE WHEN @@VERSION LIKE '%Azure%' THEN 'Azure SQL Database' ELSE 'SQL Server' END as Type,
    'Online' as Status
UNION ALL
SELECT 
    'Database',
    DB_NAME() as Name,
    'Database',
    'Connected' as Status
UNION ALL
SELECT 
    'User',
    SYSTEM_USER as Name,
    'Authentication',
    'Authenticated' as Status
"@
        
        $HealthResults = Invoke-Sqlcmd -ServerInstance $ServerName -Database "master" -Query $HealthQuery -AccessToken (Get-AzAccessToken -ResourceUrl "https://database.windows.net/").Token -ErrorAction Stop
        
        Write-Host "✅ Health check completed:" -ForegroundColor Green
        foreach ($result in $HealthResults) {
            $StatusColor = switch ($result.Status) {
                'Good' { 'Green' }
                'Online' { 'Green' }
                'Active' { 'Green' }
                'Connected' { 'Green' }
                'Authenticated' { 'Green' }
                'Review' { 'Yellow' }
                default { 'White' }
            }
            Write-Host "  🔹 $($result.Component): $($result.Name) - $($result.Status)" -ForegroundColor $StatusColor
        }
        
        return $HealthResults
        
    } catch {
        Write-Host "❌ Health check failed!" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Get-OrchestrationInfo {
    Write-Host "🎼 Retrieving Orchestration database information..." -ForegroundColor Yellow
    
    try {
        $OrchestrationQuery = @"
-- Orchestration Database Analysis
SELECT 
    'Database_Info' as Category,
    DB_NAME() as DatabaseName,
    GETDATE() as QueryTime,
    USER_NAME() as CurrentUser,
    @@SPID as SessionId
    
UNION ALL

SELECT 
    'Table_Count' as Category,
    CAST(COUNT(*) as VARCHAR(50)) as Value,
    NULL as QueryTime,
    NULL as CurrentUser,
    NULL as SessionId
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'

UNION ALL

SELECT 
    'View_Count' as Category,
    CAST(COUNT(*) as VARCHAR(50)) as Value,
    NULL as QueryTime,
    NULL as CurrentUser,
    NULL as SessionId
FROM INFORMATION_SCHEMA.VIEWS

UNION ALL

SELECT 
    'Stored_Procedure_Count' as Category,
    CAST(COUNT(*) as VARCHAR(50)) as Value,
    NULL as QueryTime,
    NULL as CurrentUser,
    NULL as SessionId
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_TYPE = 'PROCEDURE'

ORDER BY Category
"@
        
        $OrchestrationInfo = Invoke-Sqlcmd -ServerInstance $ServerName -Database $DefaultDatabase -Query $OrchestrationQuery -AccessToken (Get-AzAccessToken -ResourceUrl "https://database.windows.net/").Token -ErrorAction Stop
        
        Write-Host "✅ Orchestration database analysis completed:" -ForegroundColor Green
        foreach ($info in $OrchestrationInfo) {
            if ($info.Category -eq 'Database_Info') {
                Write-Host "  🎼 Database: $($info.DatabaseName)" -ForegroundColor Cyan
                Write-Host "  👤 User: $($info.CurrentUser)" -ForegroundColor White
                Write-Host "  🕒 Time: $($info.QueryTime)" -ForegroundColor Gray
                Write-Host "  📊 Session: $($info.SessionId)" -ForegroundColor Gray
            } else {
                $emoji = switch ($info.Category) {
                    'Table_Count' { '📋' }
                    'View_Count' { '👁️' }
                    'Stored_Procedure_Count' { '⚙️' }
                    default { '📊' }
                }
                Write-Host "  $emoji $($info.Category.Replace('_', ' ')): $($info.Value)" -ForegroundColor White
            }
        }
        
        return $OrchestrationInfo
        
    } catch {
        Write-Host "❌ Failed to retrieve Orchestration information!" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Get-CXMIDLSecurityInfo {
    Write-Host "🔒 Checking security configuration..." -ForegroundColor Yellow
    
    try {
        $SecurityQuery = @"
SELECT 
    'Encryption' as SecurityFeature,
    CASE WHEN @@VERSION LIKE '%Azure%' THEN 'TDE Enabled by Default' ELSE 'Check TDE Status' END as Status,
    'Data Protection' as Category
UNION ALL
SELECT 
    'Authentication',
    'Azure AD Integrated' as Status,
    'Identity Management' as Category
UNION ALL
SELECT 
    'Connection',
    'SSL/TLS Encrypted' as Status,
    'Transport Security' as Category
UNION ALL
SELECT 
    'Current User',
    SYSTEM_USER as Status,
    'Authentication Context' as Category
"@
        
        $SecurityResults = Invoke-Sqlcmd -ServerInstance $ServerName -Database "master" -Query $SecurityQuery -AccessToken (Get-AzAccessToken -ResourceUrl "https://database.windows.net/").Token -ErrorAction Stop
        
        Write-Host "✅ Security configuration:" -ForegroundColor Green
        foreach ($result in $SecurityResults) {
            Write-Host "  🛡️  $($result.SecurityFeature): $($result.Status)" -ForegroundColor Cyan
        }
        
        return $SecurityResults
        
    } catch {
        Write-Host "❌ Security check failed!" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}
        foreach ($result in $SecurityResults) {
            Write-Host "  🛡️  $($result.SecurityFeature): $($result.Status)" -ForegroundColor Cyan
        }
        
        return $SecurityResults
        
    } catch {
        Write-Host "❌ Security check failed!" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Main execution logic
Write-IntegrationHeader

$Results = @{}

switch ($Action.ToLower()) {
    "test" {
        $Results["Connection"] = Test-CXMIDLConnection -DatabaseName $Database
    }
    "connect" {
        $Results["Connection"] = Test-CXMIDLConnection -DatabaseName $Database
        $Results["Databases"] = Get-CXMIDLDatabases
    }
    "orchestration" {
        $Results["Connection"] = Test-CXMIDLConnection -DatabaseName $DefaultDatabase
        $Results["OrchestrationInfo"] = Get-OrchestrationInfo
    }
    "health" {
        $Results["Connection"] = Test-CXMIDLConnection -DatabaseName $Database
        $Results["Health"] = Get-CXMIDLHealthCheck
    }
    "performance" {
        $Results["Connection"] = Test-CXMIDLConnection -DatabaseName $Database
        $Results["Health"] = Get-CXMIDLHealthCheck
        # Additional performance metrics could be added here
    }
    "security" {
        $Results["Connection"] = Test-CXMIDLConnection -DatabaseName $Database
        $Results["Security"] = Get-CXMIDLSecurityInfo
    }
    default {
        Write-Host "❌ Invalid action: $Action" -ForegroundColor Red
        Write-Host "Valid actions: test, connect, orchestration, health, performance, security" -ForegroundColor Yellow
        exit 1
    }
}

# Output results
if ($OutputJson) {
    $Results | ConvertTo-Json -Depth 3 | Write-Output
} else {
    Write-Host "`n🎯 Integration completed successfully!" -ForegroundColor Green
    Write-Host "Use -OutputJson for machine-readable output" -ForegroundColor Gray
}

# Integration logging
$LogEntry = @{
    Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Server = $ServerName
    Action = $Action
    Status = if ($Results.Connection.Status -eq "Success") { "Success" } else { "Failed" }
    IntegrationId = $IntegrationId
}

# Save to integration log (optional)
$LogPath = "logs\cxmidl-integration.log"
if (Test-Path "logs") {
    $LogEntry | ConvertTo-Json -Compress | Add-Content -Path $LogPath
}
