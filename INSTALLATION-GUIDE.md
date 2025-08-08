# 🔧 Installation Guide - Dependency Conflict Resolution

## Issue: Azure CLI Dependency Conflict

**Problem**: `azure-cli` has a dependency conflict with modern Azure storage libraries:
- `azure-cli` requires `azure-storage-common~=1.4`
- `azure-storage-file>=2.1.0` requires `azure-storage-common~=2.1`

**Solution**: Install Azure CLI separately from Python packages.

---

## ✅ Recommended Installation Steps

### 1. **Install Python Dependencies**
```powershell
# Install base requirements (no conflicts)
pip install -r requirements.txt

# Install dev requirements (azure-cli removed)
pip install -r requirements-dev.txt
```

### 2. **Install Azure CLI Separately**

#### **Option A: Windows Package Manager (Recommended)**
```powershell
# Using winget (Windows 10/11)
winget install Microsoft.AzureCLI

# Using Chocolatey
choco install azure-cli
```

#### **Option B: MSI Installer**
1. Download from: https://aka.ms/installazurecliwindows
2. Run the installer as administrator
3. Restart your terminal/VS Code

#### **Option C: Python (Alternative - may have conflicts)**
```powershell
# Only if you need azure-cli in Python environment
# Create separate environment for azure-cli
python -m venv .venv-azurecli
.venv-azurecli\Scripts\activate
pip install azure-cli
deactivate
```

### 3. **Verify Installation**
```powershell
# Check Azure CLI (should work from any terminal)
az --version

# Check Python environment
python scripts/validate-environment.py

# Test both together
az account show
python -c "import azure.identity; print('Azure SDK: OK')"
```

---

## 🎯 Why This Approach Works

### **Separation of Concerns**
- **Azure CLI**: Command-line tool with its own dependency tree
- **Python SDK**: Modern Azure libraries for development
- **No Conflicts**: Each tool uses its own dependencies

### **Best Practices**
- ✅ Use Azure CLI for command-line operations
- ✅ Use Azure SDK (already in requirements.txt) for Python development
- ✅ Keep development tools separate from runtime dependencies

---

## 🔧 Alternative Solutions (If You Must Have azure-cli in Python)

### **Option 1: Downgrade Storage Libraries**
```powershell
# WARNING: This may break OneLake/Fabric functionality
pip install azure-storage-file==1.4.0
pip install azure-cli>=2.50.0
```

### **Option 2: Use Older Azure CLI**
```powershell
# Try older azure-cli that might have compatible dependencies
pip install azure-cli==2.49.0
```

### **Option 3: Virtual Environment per Tool**
```powershell
# Main development environment
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt

# Separate Azure CLI environment
python -m venv .venv-cli
.venv-cli\Scripts\activate
pip install azure-cli
deactivate

# Use aliases to switch
# alias az-cli=".venv-cli\Scripts\activate && az"
```

---

## 🚀 Recommended Workflow

### **Daily Development**
```powershell
# 1. Activate main Python environment
.venv\Scripts\activate

# 2. Use Azure CLI from system installation
az login
az account set --subscription "your-subscription"

# 3. Use Python for development
python scripts/validate-environment.py
jupyter lab
```

### **Azure Operations**
```powershell
# Azure CLI commands (no conflicts)
az storage account list
az synapse workspace list
az group list

# Python SDK operations (no conflicts)
python -c "
from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient
cred = DefaultAzureCredential()
print('Azure SDK authenticated successfully')
"
```

---

## 📋 Summary

| Tool | Installation Method | Use Case |
|------|-------------------|-----------|
| **Azure CLI** | System package (winget/MSI) | Command-line operations |
| **Azure Python SDK** | pip (requirements.txt) | Python development |
| **Development Tools** | pip (requirements-dev.txt) | Code quality, testing |

**Result**: ✅ No dependency conflicts, full functionality for both tools.

---

## 🔍 Verification Commands

```powershell
# Check Azure CLI
az --version
az account show

# Check Python environment
python -c "import azure.identity, azure.mgmt.storage; print('Azure SDK: OK')"
python -c "import pandas, numpy, pyspark; print('Data stack: OK')"
python -c "import jupyter, notebook; print('Jupyter: OK')"

# Check development tools
python -c "import pytest, black, mypy; print('Dev tools: OK')"

# Full environment validation
python scripts/validate-environment.py
```

This approach provides the best of both worlds without dependency conflicts!
