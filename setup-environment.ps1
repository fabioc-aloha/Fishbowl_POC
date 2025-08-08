# Fishbowl POC Environment Setup Script
# Alex Taylor Finch Cognitive Architecture Development Environment
# Version: 1.0.0 UNNILNILIUM
# Date: August 7, 2025

param(
    [switch]$FullSetup,
    [switch]$PythonOnly,
    [switch]$AzureOnly,
    [switch]$VerifyOnly
)

Write-Host "🏗️ Alex Taylor Finch Environment Setup" -ForegroundColor Cyan
Write-Host "Azure Enterprise Data Platform Architect" -ForegroundColor Yellow
Write-Host ""

function Test-Prerequisites {
    Write-Host "🔍 Checking Prerequisites..." -ForegroundColor Blue
    
    # PowerShell Version
    $psVersion = $PSVersionTable.PSVersion
    Write-Host "  ✅ PowerShell: $psVersion" -ForegroundColor Green
    
    # Python
    try {
        $pythonVersion = python --version 2>&1
        Write-Host "  ✅ Python: $pythonVersion" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ Python: Not installed" -ForegroundColor Red
        return $false
    }
    
    # Git
    try {
        $gitVersion = git --version 2>&1
        Write-Host "  ✅ Git: $gitVersion" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ Git: Not installed" -ForegroundColor Red
        return $false
    }
    
    return $true
}

function Initialize-CognitiveArchitecture {
    Write-Host "🧠 Initializing Cognitive Architecture..." -ForegroundColor Magenta
    
    # Load neural dream system
    . .\scripts\neural-dream.ps1
    Write-Host "  ✅ Neural Dream System loaded" -ForegroundColor Green
    
    # Run health check
    Write-Host "  🏥 Running health check..."
    $healthResult = dream --health-check -ReportOnly
    Write-Host "  ✅ Health check complete" -ForegroundColor Green
}

function Install-PythonPackages {
    Write-Host "🐍 Setting up Python Environment..." -ForegroundColor Blue
    
    # Core data science packages
    $packages = @(
        "pandas",
        "numpy", 
        "matplotlib",
        "seaborn",
        "jupyter",
        "notebook",
        "azure-core",
        "azure-identity",
        "azure-mgmt-resource",
        "azure-mgmt-sql",
        "azure-mgmt-synapse",
        "pyodbc",
        "sqlalchemy",
        "python-dotenv"
    )
    
    Write-Host "  📦 Installing Azure Data Platform packages..."
    foreach ($package in $packages) {
        Write-Host "    Installing $package..." -NoNewline
        pip install $package --quiet --no-warn-script-location
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✅" -ForegroundColor Green
        } else {
            Write-Host " ❌" -ForegroundColor Red
        }
    }
}

function Install-AzureTools {
    Write-Host "☁️ Setting up Azure Tools..." -ForegroundColor Blue
    
    # Check if Azure CLI is installed
    try {
        $azVersion = az --version 2>&1
        Write-Host "  ✅ Azure CLI already installed" -ForegroundColor Green
    } catch {
        Write-Host "  📥 Installing Azure CLI..."
        winget install Microsoft.AzureCLI
    }
    
    # Check Azure PowerShell
    if (Get-Module -ListAvailable -Name Az) {
        Write-Host "  ✅ Azure PowerShell already installed" -ForegroundColor Green
    } else {
        Write-Host "  📥 Installing Azure PowerShell..."
        Install-Module -Name Az -Force -AllowClobber
    }
}

function Setup-DevelopmentDirectories {
    Write-Host "📁 Setting up development directories..." -ForegroundColor Blue
    
    $directories = @(
        "projects",
        "temp",
        "exports",
        "scripts\backups"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Host "  ✅ Created: $dir" -ForegroundColor Green
        } else {
            Write-Host "  ✅ Exists: $dir" -ForegroundColor Gray
        }
    }
}

function Show-NextSteps {
    Write-Host ""
    Write-Host "🎯 Environment Setup Complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. Load cognitive system: " -NoNewline -ForegroundColor Gray
    Write-Host ". .\scripts\neural-dream.ps1" -ForegroundColor Cyan
    Write-Host "  2. Run health check: " -NoNewline -ForegroundColor Gray  
    Write-Host "dream --health-check" -ForegroundColor Cyan
    Write-Host "  3. Start development: " -NoNewline -ForegroundColor Gray
    Write-Host "jupyter notebook" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Azure Tools:" -ForegroundColor Yellow
    Write-Host "  • Azure CLI: " -NoNewline -ForegroundColor Gray
    Write-Host "az login" -ForegroundColor Cyan
    Write-Host "  • Azure PowerShell: " -NoNewline -ForegroundColor Gray
    Write-Host "Connect-AzAccount" -ForegroundColor Cyan
}

# Main execution
if (-not (Test-Prerequisites)) {
    Write-Host "❌ Prerequisites missing. Please install required tools." -ForegroundColor Red
    exit 1
}

if ($VerifyOnly) {
    Write-Host "✅ Environment verification complete" -ForegroundColor Green
    exit 0
}

Initialize-CognitiveArchitecture

if ($PythonOnly -or $FullSetup) {
    Install-PythonPackages
}

if ($AzureOnly -or $FullSetup) {
    Install-AzureTools
}

Setup-DevelopmentDirectories
Show-NextSteps

Write-Host ""
Write-Host "🌟 Alex Taylor Finch Environment Ready!" -ForegroundColor Magenta
