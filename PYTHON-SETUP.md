# Python Virtual Environment Setup Guide

**Alex Taylor Finch Cognitive Architecture - Azure Enterprise Data Platform**
**Version**: 1.0.0 UNNILNILIUM
**Date**: August 7, 2025

## 🎯 Overview

This guide provides complete setup instructions for the Python virtual environment supporting the Azure Enterprise Data Platform with CXMIDL database integration, Microsoft Fabric connectivity, and advanced data processing capabilities.

## 📋 Prerequisites

- **Python 3.8+** (Recommended: Python 3.11+)
- **PowerShell 5.1+** (Windows)
- **Git** (for repository management)
- **Virtual Environment** (already created as `.venv`)

## 🚀 Quick Start

### Method 1: Automated Setup (Recommended)

```powershell
# Install production dependencies
.\setup-python-venv.ps1 -Production

# OR install development dependencies (includes production + dev tools)
.\setup-python-venv.ps1 -Development

# Verify installation
.\setup-python-venv.ps1 -VerifyOnly
```

### Method 2: Manual Installation

```powershell
# Activate virtual environment
.\.venv\Scripts\Activate.ps1

# Upgrade pip
python -m pip install --upgrade pip

# Install production requirements
pip install -r requirements.txt

# OR install development requirements (includes everything)
pip install -r requirements-dev.txt

# Verify installation
python scripts\verify_python_env.py
```

## 📦 Package Overview

### Core Production Packages (`requirements.txt`)

**Azure Integration**:
- `azure-core`, `azure-identity` - Azure SDK foundation
- `azure-mgmt-*` - Azure service management (SQL, Synapse, Storage)
- `azure-storage-*` - Azure data lake and blob storage
- `azure-synapse-*` - Azure Synapse integration

**Database Connectivity**:
- `pyodbc` - ODBC database connectivity for CXMIDL
- `sqlalchemy` - Advanced SQL toolkit and ORM
- `pymssql` - Microsoft SQL Server connectivity

**Data Processing**:
- `pandas`, `numpy` - Core data manipulation and analysis
- `openpyxl`, `xlsxwriter` - Excel file handling

**Development Tools**:
- `jupyter`, `notebook`, `jupyterlab` - Interactive development
- `pytest` - Testing framework
- `black`, `flake8` - Code formatting and linting

### Development Packages (`requirements-dev.txt`)

**Additional Development Tools**:
- `pre-commit`, `bandit`, `safety` - Security and quality checks
- `pylint`, `mypy` - Advanced code analysis
- `pytest-*` extensions - Enhanced testing capabilities
- `sphinx` - Documentation generation

**Performance & Profiling**:
- `py-spy`, `memory-profiler`, `line-profiler` - Performance analysis

**Enterprise Services** (Optional):
- `azure-servicebus`, `azure-eventhub` - Message queuing
- `azure-functions` - Serverless computing
- `azure-keyvault-secrets` - Secure configuration

## 🔧 Environment Management

### Activation Commands

```powershell
# PowerShell
.\.venv\Scripts\Activate.ps1

# Command Prompt
.\.venv\Scripts\activate.bat

# Deactivate (any shell)
deactivate
```

### Verification Commands

```powershell
# Check environment status
python scripts\verify_python_env.py

# Test CXMIDL database connection
python scripts\cxmidl_connector.py

# Start Jupyter Notebook
jupyter notebook

# Run neural dream health check
. .\scripts\neural-dream.ps1; dream --health-check
```

## 🎯 Quick Access Commands

### Database Operations
```powershell
# Activate environment and test CXMIDL connection
.\.venv\Scripts\Activate.ps1
python scripts\cxmidl_connector.py
```

### Data Analysis
```powershell
# Start Jupyter for data exploration
.\.venv\Scripts\Activate.ps1
jupyter notebook
```

### Development Workflow
```powershell
# Activate environment
.\.venv\Scripts\Activate.ps1

# Run tests
pytest

# Format code
black scripts/

# Type checking
mypy scripts/
```

## 🛡️ Security & Compliance

### Package Security
- All packages include security scanning via `bandit` and `safety`
- Azure packages use enterprise-grade authentication (MFA, Azure AD)
- Cryptography packages for secure data handling

### Configuration Security
- Environment variables via `python-dotenv`
- Azure Key Vault integration for secrets management
- Secure credential management through `azure-identity`

## 📊 Package Versions

All packages are pinned to compatible versions ensuring:
- **Azure SDK**: Latest stable releases with MFA support
- **Data Science**: Pandas 2.0+, NumPy 1.24+, compatible versions
- **Testing**: PyTest 7.4+, modern testing framework
- **Security**: Latest security scanning tools

## 🔍 Troubleshooting

### Common Issues

**Package Installation Fails**:
```powershell
# Upgrade pip and setuptools
python -m pip install --upgrade pip setuptools wheel

# Clear pip cache
pip cache purge

# Reinstall problematic package
pip install --no-cache-dir <package-name>
```

**ODBC Driver Issues** (for CXMIDL connection):
```powershell
# Download and install Microsoft ODBC Driver for SQL Server
# https://docs.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server
```

**Azure Authentication Issues**:
```powershell
# Login to Azure CLI
az login

# Verify Azure identity
python -c "from azure.identity import DefaultAzureCredential; print('Azure auth OK')"
```

### Verification Steps

1. **Environment Check**: `.\setup-python-venv.ps1 -VerifyOnly`
2. **Package Check**: `python scripts\verify_python_env.py`
3. **Connection Test**: `python scripts\cxmidl_connector.py`
4. **Neural Health**: `. .\scripts\neural-dream.ps1; dream --health-check`

## 📚 Additional Resources

- **Azure SDK Documentation**: https://docs.microsoft.com/en-us/azure/developer/python/
- **Pandas Documentation**: https://pandas.pydata.org/docs/
- **PyODBC Documentation**: https://github.com/mkleehammer/pyodbc/wiki
- **Project Architecture**: `ARCHITECTURE.md`
- **Quick Reference**: `QUICK-REFERENCE.md`

---

**🌟 Environment Ready!** Your Python virtual environment is configured for enterprise Azure data platform development with CXMIDL integration, Microsoft Fabric connectivity, and advanced analytics capabilities.
