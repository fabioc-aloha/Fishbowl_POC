# CXMIDL Stored Procedure Discovery and Analysis Script
# Alex Taylor Finch Cognitive Architecture - Orchestration to Fabric Migration
# Version: 1.0.0 UNNILPENTIUM

param(
    [Parameter()]
    [ValidateSet("list", "analyze", "classify", "dependencies", "export")]
    [string]$Action = "list",
    
    [Parameter()]
    [switch]$UseMFA,
    
    [Parameter()]
    [switch]$Detailed,
    
    [Parameter()]
    [string]$OutputPath = ".\migration-analysis",
    
    [Parameter()]
    [string]$ProcedureName = ""
)

# Enterprise configuration
$ServerName = "cxmidl.database.windows.net"
$DatabaseName = "Orchestration"
$IntegrationId = "stored-procedure-discovery"

# Import required modules
try {
    Import-Module SqlServer -ErrorAction SilentlyContinue
} catch {
    Write-Warning "SqlServer module may not be installed. Use 'Install-Module SqlServer' for full functionality."
}

function Write-DiscoveryHeader {
    Write-Host "🔍 CXMIDL Stored Procedure Discovery & Analysis" -ForegroundColor Cyan
    Write-Host "Server: $ServerName" -ForegroundColor Green
    Write-Host "Database: $DatabaseName" -ForegroundColor Yellow
    Write-Host "Action: $Action" -ForegroundColor Magenta
    Write-Host "MFA Mode: $(if($UseMFA) {'✅ Interactive'} else {'🔑 Azure CLI Token'})" -ForegroundColor $(if($UseMFA) {'Green'} else {'Yellow'})
    Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host "=" * 70 -ForegroundColor DarkCyan
    Write-Host ""
}

function Get-DatabaseConnection {
    try {
        if ($UseMFA) {
            $ConnectionString = "Server=$ServerName;Database=$DatabaseName;Authentication=Active Directory Interactive;"
        } else {
            $ConnectionString = "Server=$ServerName;Database=$DatabaseName;Authentication=Active Directory Integrated;"
        }
        
        # Test connection
        $TestQuery = "SELECT DB_NAME() as DatabaseName, SUSER_NAME() as UserName, @@VERSION as Version"
        $TestResult = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $TestQuery -QueryTimeout 30
        
        Write-Host "✅ Connected to database: $($TestResult.DatabaseName)" -ForegroundColor Green
        Write-Host "👤 User: $($TestResult.UserName)" -ForegroundColor Gray
        
        return $ConnectionString
    } catch {
        Write-Host "❌ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

function Get-StoredProcedureList {
    param($ConnectionString)
    
    Write-Host "📋 Retrieving stored procedure list..." -ForegroundColor Yellow
    
    $Query = @"
SELECT 
    p.name AS procedure_name,
    s.name AS schema_name,
    p.create_date,
    p.modify_date,
    p.object_id,
    CASE 
        WHEN p.name LIKE '%test%' OR p.name LIKE '%temp%' THEN 'Testing/Temporary'
        WHEN p.name LIKE '%etl%' OR p.name LIKE '%extract%' OR p.name LIKE '%load%' THEN 'ETL Operations'
        WHEN p.name LIKE '%report%' OR p.name LIKE '%summary%' THEN 'Reporting'
        WHEN p.name LIKE '%config%' OR p.name LIKE '%setting%' THEN 'Configuration'
        WHEN p.name LIKE '%audit%' OR p.name LIKE '%log%' THEN 'Auditing/Logging'
        WHEN p.name LIKE '%workflow%' OR p.name LIKE '%orchestr%' THEN 'Orchestration'
        ELSE 'Business Logic'
    END AS category,
    LEN(m.definition) AS code_length
FROM sys.procedures p
INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
INNER JOIN sys.sql_modules m ON p.object_id = m.object_id
WHERE p.is_ms_shipped = 0
ORDER BY p.name
"@
    
    $Results = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $Query -QueryTimeout 60
    return $Results
}

function Get-ProcedureComplexityAnalysis {
    param($ConnectionString)
    
    Write-Host "🔬 Analyzing procedure complexity..." -ForegroundColor Yellow
    
    $Query = @"
SELECT 
    p.name AS procedure_name,
    s.name AS schema_name,
    LEN(m.definition) AS code_length,
    -- Complexity indicators
    (LEN(m.definition) - LEN(REPLACE(UPPER(m.definition), 'CURSOR', ''))) / LEN('CURSOR') AS cursor_count,
    (LEN(m.definition) - LEN(REPLACE(UPPER(m.definition), 'TRANSACTION', ''))) / LEN('TRANSACTION') AS transaction_count,
    (LEN(m.definition) - LEN(REPLACE(UPPER(m.definition), 'EXEC', ''))) / LEN('EXEC') AS dynamic_sql_count,
    (LEN(m.definition) - LEN(REPLACE(UPPER(m.definition), 'WHILE', ''))) / LEN('WHILE') AS loop_count,
    (LEN(m.definition) - LEN(REPLACE(UPPER(m.definition), 'IF', ''))) / LEN('IF') AS conditional_count,
    (LEN(m.definition) - LEN(REPLACE(UPPER(m.definition), 'TRY', ''))) / LEN('TRY') AS error_handling_count,
    -- Migration difficulty classification
    CASE 
        WHEN LEN(m.definition) < 1000 AND 
             (LEN(m.definition) - LEN(REPLACE(UPPER(m.definition), 'SELECT', ''))) / LEN('SELECT') <= 2 AND
             (LEN(m.definition) - LEN(REPLACE(UPPER(m.definition), 'CURSOR', ''))) / LEN('CURSOR') = 0
        THEN 'Simple'
        WHEN LEN(m.definition) < 5000 AND
             (LEN(m.definition) - LEN(REPLACE(UPPER(m.definition), 'CURSOR', ''))) / LEN('CURSOR') <= 1 AND
             (LEN(m.definition) - LEN(REPLACE(UPPER(m.definition), 'TRANSACTION', ''))) / LEN('TRANSACTION') <= 2
        THEN 'Medium'
        ELSE 'Complex'
    END AS complexity_level,
    -- Recommended migration path
    CASE 
        WHEN p.name LIKE '%report%' OR p.name LIKE '%summary%' OR p.name LIKE '%get%' 
        THEN 'Fabric Data Warehouse'
        WHEN p.name LIKE '%etl%' OR p.name LIKE '%transform%' OR LEN(m.definition) > 3000
        THEN 'Spark Notebooks'
        WHEN p.name LIKE '%workflow%' OR p.name LIKE '%orchestr%' OR p.name LIKE '%batch%'
        THEN 'Fabric Pipelines'
        ELSE 'Fabric Data Warehouse'
    END AS recommended_target
FROM sys.procedures p
INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
INNER JOIN sys.sql_modules m ON p.object_id = m.object_id
WHERE p.is_ms_shipped = 0
ORDER BY 
    CASE complexity_level 
        WHEN 'Simple' THEN 1 
        WHEN 'Medium' THEN 2 
        WHEN 'Complex' THEN 3 
    END,
    LEN(m.definition) DESC
"@
    
    $Results = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $Query -QueryTimeout 120
    return $Results
}

function Get-ProcedureDependencies {
    param($ConnectionString)
    
    Write-Host "🔗 Analyzing procedure dependencies..." -ForegroundColor Yellow
    
    $Query = @"
WITH ProcedureDependencies AS (
    SELECT 
        p.name AS procedure_name,
        dep.referenced_entity_name AS depends_on,
        dep.referenced_schema_name AS schema_name,
        CASE dep.referenced_class
            WHEN 1 THEN 'Table/View'
            WHEN 6 THEN 'Type'
            WHEN 10 THEN 'XML Schema'
            WHEN 21 THEN 'Function'
        END AS dependency_type
    FROM sys.procedures p
    INNER JOIN sys.sql_expression_dependencies dep 
        ON p.object_id = dep.referencing_id
    WHERE dep.referenced_id IS NOT NULL
      AND p.is_ms_shipped = 0
)
SELECT 
    procedure_name,
    COUNT(*) AS total_dependencies,
    COUNT(CASE WHEN dependency_type = 'Table/View' THEN 1 END) AS table_dependencies,
    COUNT(CASE WHEN dependency_type = 'Function' THEN 1 END) AS function_dependencies,
    STRING_AGG(CAST(depends_on AS NVARCHAR(MAX)), ', ') AS dependent_objects
FROM ProcedureDependencies
GROUP BY procedure_name
ORDER BY total_dependencies DESC
"@
    
    $Results = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $Query -QueryTimeout 120
    return $Results
}

function Export-ProcedureDefinition {
    param($ConnectionString, $ProcName)
    
    Write-Host "📤 Exporting procedure definition for: $ProcName" -ForegroundColor Yellow
    
    $Query = @"
SELECT 
    p.name AS procedure_name,
    s.name AS schema_name,
    m.definition AS procedure_definition,
    p.create_date,
    p.modify_date
FROM sys.procedures p
INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
INNER JOIN sys.sql_modules m ON p.object_id = m.object_id
WHERE p.name = '$ProcName' AND p.is_ms_shipped = 0
"@
    
    $Results = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $Query -QueryTimeout 60
    return $Results
}

function Save-ResultsToFile {
    param($Results, $FileName, $Format = "CSV")
    
    if (!(Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath | Out-Null
        Write-Host "📁 Created output directory: $OutputPath" -ForegroundColor Green
    }
    
    $FilePath = Join-Path $OutputPath $FileName
    
    switch ($Format.ToUpper()) {
        "CSV" {
            $Results | Export-Csv -Path "$FilePath.csv" -NoTypeInformation
            Write-Host "💾 Results saved to: $FilePath.csv" -ForegroundColor Green
        }
        "JSON" {
            $Results | ConvertTo-Json -Depth 5 | Out-File -FilePath "$FilePath.json" -Encoding UTF8
            Write-Host "💾 Results saved to: $FilePath.json" -ForegroundColor Green
        }
        "TXT" {
            $Results | Format-Table -AutoSize | Out-File -FilePath "$FilePath.txt" -Encoding UTF8
            Write-Host "💾 Results saved to: $FilePath.txt" -ForegroundColor Green
        }
    }
}

# Main execution
Write-DiscoveryHeader

try {
    # Get database connection
    $ConnectionString = Get-DatabaseConnection
    
    # Execute based on action
    switch ($Action) {
        "list" {
            $Procedures = Get-StoredProcedureList -ConnectionString $ConnectionString
            
            Write-Host "📊 Found $($Procedures.Count) stored procedures:" -ForegroundColor Green
            
            if ($Detailed) {
                $Procedures | Format-Table procedure_name, schema_name, category, create_date, code_length -AutoSize
                Save-ResultsToFile -Results $Procedures -FileName "procedure_list_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            } else {
                $Procedures | Select-Object procedure_name, category | Format-Table -AutoSize
            }
            
            # Category summary
            $CategorySummary = $Procedures | Group-Object category | Select-Object Name, Count | Sort-Object Count -Descending
            Write-Host "`n📈 Procedures by Category:" -ForegroundColor Cyan
            $CategorySummary | Format-Table -AutoSize
        }
        
        "analyze" {
            $Analysis = Get-ProcedureComplexityAnalysis -ConnectionString $ConnectionString
            
            Write-Host "🔬 Complexity Analysis Results:" -ForegroundColor Green
            
            if ($Detailed) {
                $Analysis | Format-Table procedure_name, complexity_level, recommended_target, code_length, cursor_count, transaction_count -AutoSize
                Save-ResultsToFile -Results $Analysis -FileName "complexity_analysis_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            } else {
                $ComplexitySummary = $Analysis | Group-Object complexity_level | Select-Object Name, Count
                $TargetSummary = $Analysis | Group-Object recommended_target | Select-Object Name, Count
                
                Write-Host "`n📊 Complexity Distribution:" -ForegroundColor Cyan
                $ComplexitySummary | Format-Table -AutoSize
                
                Write-Host "`n🎯 Recommended Migration Targets:" -ForegroundColor Cyan
                $TargetSummary | Format-Table -AutoSize
            }
        }
        
        "dependencies" {
            $Dependencies = Get-ProcedureDependencies -ConnectionString $ConnectionString
            
            Write-Host "🔗 Dependency Analysis Results:" -ForegroundColor Green
            
            if ($Detailed) {
                $Dependencies | Format-Table procedure_name, total_dependencies, table_dependencies, function_dependencies -AutoSize
                Save-ResultsToFile -Results $Dependencies -FileName "dependencies_analysis_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            } else {
                $TopDependencies = $Dependencies | Select-Object -First 10
                $TopDependencies | Format-Table procedure_name, total_dependencies, table_dependencies -AutoSize
            }
        }
        
        "export" {
            if ($ProcedureName) {
                $ProcDefinition = Export-ProcedureDefinition -ConnectionString $ConnectionString -ProcName $ProcedureName
                
                if ($ProcDefinition) {
                    Write-Host "📤 Exporting procedure: $($ProcDefinition.procedure_name)" -ForegroundColor Green
                    
                    $FileName = "procedure_$($ProcDefinition.procedure_name)_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
                    Save-ResultsToFile -Results $ProcDefinition -FileName $FileName -Format "JSON"
                    
                    # Also save just the SQL definition
                    $SqlFile = Join-Path $OutputPath "$FileName.sql"
                    $ProcDefinition.procedure_definition | Out-File -FilePath $SqlFile -Encoding UTF8
                    Write-Host "💾 SQL definition saved to: $SqlFile" -ForegroundColor Green
                } else {
                    Write-Host "❌ Procedure '$ProcedureName' not found" -ForegroundColor Red
                }
            } else {
                Write-Host "❌ Please specify -ProcedureName parameter for export action" -ForegroundColor Red
                exit 1
            }
        }
        
        "classify" {
            $Procedures = Get-StoredProcedureList -ConnectionString $ConnectionString
            $Analysis = Get-ProcedureComplexityAnalysis -ConnectionString $ConnectionString
            
            # Combine results for classification
            $Classification = $Analysis | Select-Object procedure_name, complexity_level, recommended_target, code_length
            
            Write-Host "🏷️ Migration Classification Results:" -ForegroundColor Green
            
            # Group by migration target
            $MigrationPlan = $Classification | Group-Object recommended_target
            
            foreach ($Target in $MigrationPlan) {
                Write-Host "`n🎯 $($Target.Name) ($($Target.Count) procedures):" -ForegroundColor Cyan
                
                $TargetProcs = $Target.Group | Sort-Object complexity_level, code_length
                foreach ($Proc in $TargetProcs) {
                    $ComplexityColor = switch ($Proc.complexity_level) {
                        "Simple" { "Green" }
                        "Medium" { "Yellow" }
                        "Complex" { "Red" }
                    }
                    Write-Host "  📋 $($Proc.procedure_name) [$($Proc.complexity_level)] ($($Proc.code_length) chars)" -ForegroundColor $ComplexityColor
                }
            }
            
            if ($Detailed) {
                Save-ResultsToFile -Results $Classification -FileName "migration_classification_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            }
        }
    }
    
    Write-Host "`n🎯 Discovery completed successfully!" -ForegroundColor Green
    Write-Host "📊 Integration ID: $IntegrationId" -ForegroundColor Gray
    Write-Host "🕒 Completed: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Discovery failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
