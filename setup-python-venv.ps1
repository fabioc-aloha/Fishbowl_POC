# Python Virtual Environment Setup Script
# Alex Taylor Finch Cognitive Architecture - Azure Enterprise Data Platform
# Version: 1.0.0 UNNILNILIUM
# Date: August 7, 2025

param(
    [switch]$Production,
    [switch]$Development,
    [switch]$VerifyOnly,
    [string]$VenvPath = ".venv"
)

Write-Host "🐍 Python Virtual Environment Setup" -ForegroundColor Cyan
Write-Host "Azure Enterprise Data Platform Dependencies" -ForegroundColor Yellow
Write-Host ""

function Test-PythonInstallation {
    Write-Host "🔍 Checking Python Installation..." -ForegroundColor Blue
    
    try {
        $pythonVersion = python --version 2>&1
        Write-Host "  ✅ Python: $pythonVersion" -ForegroundColor Green
        
        # Check if python version is 3.8+
        if ($pythonVersion -match "Python (\d+)\.(\d+)") {
            $major = [int]$matches[1]
            $minor = [int]$matches[2]
            if ($major -ge 3 -and $minor -ge 8) {
                Write-Host "  ✅ Python version is compatible (3.8+)" -ForegroundColor Green
                return $true
            } else {
                Write-Host "  ❌ Python version must be 3.8 or higher" -ForegroundColor Red
                return $false
            }
        }
    } catch {
        Write-Host "  ❌ Python: Not installed or not in PATH" -ForegroundColor Red
        return $false
    }
}

function Test-VirtualEnvironment {
    if (Test-Path $VenvPath) {
        Write-Host "  ✅ Virtual environment exists: $VenvPath" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ❌ Virtual environment not found: $VenvPath" -ForegroundColor Red
        return $false
    }
}

function New-VirtualEnvironment {
    Write-Host "🏗️ Creating Virtual Environment..." -ForegroundColor Blue
    
    python -m venv $VenvPath
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Virtual environment created: $VenvPath" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ❌ Failed to create virtual environment" -ForegroundColor Red
        return $false
    }
}

function Install-Requirements {
    param([string]$RequirementsFile)
    
    Write-Host "📦 Installing requirements from: $RequirementsFile" -ForegroundColor Blue
    
    # Upgrade pip first
    Write-Host "  🔄 Upgrading pip..." -ForegroundColor Gray
    python -m pip install --upgrade pip
    
    # Install requirements
    Write-Host "  📥 Installing packages..." -ForegroundColor Gray
    python -m pip install -r $RequirementsFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Requirements installed successfully" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ❌ Failed to install requirements" -ForegroundColor Red
        return $false
    }
}

function Show-ActivationInstructions {
    Write-Host ""
    Write-Host "🎯 Virtual Environment Ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To activate the virtual environment:" -ForegroundColor Yellow
    Write-Host "  PowerShell: " -NoNewline -ForegroundColor Gray
    Write-Host "$VenvPath\Scripts\Activate.ps1" -ForegroundColor Cyan
    Write-Host "  Command Prompt: " -NoNewline -ForegroundColor Gray
    Write-Host "$VenvPath\Scripts\activate.bat" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To deactivate:" -ForegroundColor Yellow
    Write-Host "  " -NoNewline -ForegroundColor Gray
    Write-Host "deactivate" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Quick Start Commands:" -ForegroundColor Yellow
    Write-Host "  Test CXMIDL connection: " -NoNewline -ForegroundColor Gray
    Write-Host "python scripts/cxmidl_connector.py" -ForegroundColor Cyan
    Write-Host "  Start Jupyter: " -NoNewline -ForegroundColor Gray
    Write-Host "jupyter notebook" -ForegroundColor Cyan
}

function Show-VerificationStatus {
    Write-Host "🔍 Environment Verification:" -ForegroundColor Blue
    
    # Check virtual environment
    if (Test-VirtualEnvironment) {
        Write-Host "  ✅ Virtual Environment: $VenvPath" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Virtual Environment: Not found" -ForegroundColor Red
    }
    
    # Check if activated
    if ($env:VIRTUAL_ENV) {
        Write-Host "  ✅ Currently Activated: $env:VIRTUAL_ENV" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️ Virtual Environment: Not activated" -ForegroundColor Yellow
    }
    
    # Check requirements files
    if (Test-Path "requirements.txt") {
        Write-Host "  ✅ Production Requirements: requirements.txt" -ForegroundColor Green
    }
    if (Test-Path "requirements-dev.txt") {
        Write-Host "  ✅ Development Requirements: requirements-dev.txt" -ForegroundColor Green
    }
}

# Main execution
if (-not (Test-PythonInstallation)) {
    Write-Host "❌ Python installation issues. Please install Python 3.8+ and try again." -ForegroundColor Red
    exit 1
}

if ($VerifyOnly) {
    Show-VerificationStatus
    exit 0
}

# Create virtual environment if it doesn't exist
if (-not (Test-VirtualEnvironment)) {
    if (-not (New-VirtualEnvironment)) {
        exit 1
    }
}

# Activate virtual environment (for this session)
if (Test-Path "$VenvPath\Scripts\Activate.ps1") {
    & "$VenvPath\Scripts\Activate.ps1"
    Write-Host "  ✅ Virtual environment activated" -ForegroundColor Green
}

# Install requirements based on flags
if ($Development) {
    Install-Requirements "requirements-dev.txt"
} elseif ($Production) {
    Install-Requirements "requirements.txt"
} else {
    # Default to production requirements
    Install-Requirements "requirements.txt"
}

Show-ActivationInstructions

Write-Host ""
Write-Host "🌟 Python Environment Setup Complete!" -ForegroundColor Magenta
