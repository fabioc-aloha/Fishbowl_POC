# 🚀 Fishbowl POC - Quick Reference Guide

## 🎯 **Project Status: ✅ CONNECTED & OPERATIONAL**

**Integration**: Azure Synapse Analytics ↔ Microsoft Fabric
**Environment**: Microsoft IT (MSIT) with MCAS proxy
**Status**: Data exploration and analytics development phase
**Last Updated**: August 7, 2025

---

## 🔗 **Essential Access URLs**

| Service | URL | Status |
|---------|-----|--------|
| **🏢 Fabric Workspace** | https://msit.powerbi.com.mcas.ms/ | ✅ Operational |
| **📊 Fishbowl_POC Workspace** | Workspace ID: `1dfcfdc6-64ff-4338-8eec-2676ff0f5884` | ✅ Connected |
| **🏠 SynapseDataLake Lakehouse** | Access via Fabric workspace | ✅ Active |
| **☁️ Azure Portal** | https://portal.azure.com | ✅ Accessible |
| **💾 cpestaginglake Storage** | https://cpestaginglake.dfs.core.windows.net/ | ✅ Connected |
| **⚡ Synapse Workspace** | cpesynapse.sql.azuresynapse.net | ✅ Operational |

---

## 📂 **Connected Data Containers**

| Container | Path | Priority | Contents | Use Cases |
|-----------|------|----------|----------|-----------|
| **📁 synapse** | `/Files/synapse` | **HIGH** | ETL data, pipelines, processed datasets | **Start here for data exploration** |
| **📁 machinelearning** | `/Files/ml` | Medium | ML models, experiments, artifacts | Model analysis, ML workflows |
| **📁 aas-container** | `/Files/aas` | Medium | Analysis Services data, cubes | Dimensional analysis, OLAP |
| **📁 test** | `/Files/test` | Low | Test datasets, validation data | Testing, development, samples |

---

## ⚡ **Quick Access Commands**

### **Environment Setup & Validation**
```powershell
# Validate environment configuration
python scripts/validate-environment.py

# Setup Python environment with dependencies
.\setup-environment.ps1 -PythonOnly

# Install required packages including dotenv
pip install -r requirements.txt
```

### **Environment Configuration**
```bash
# Copy template and configure environment
cp .env.template .env
# Edit .env file with your specific values

# Key variables to set:
# FABRIC_WORKSPACE_ID=1dfcfdc6-64ff-4338-8eec-2676ff0f5884
# STORAGE_ACCOUNT_NAME=cpestaginglake
# DATA_FORMAT=PARQUET
# TABLE_PREFIX=staging_
```

### **Environment & Connection**
```powershell
# Check Azure authentication
az account show --query "{subscription: name, user: user.name, tenant: tenantId}"

# Verify storage access
az storage account show --name cpestaginglake --resource-group integration

# Test Fabric workspace access
# Navigate to: https://msit.powerbi.com.mcas.ms/ → Fishbowl_POC
```

### **Data Exploration**
```sql
-- Query connected data via SQL endpoint
SELECT TOP 100 * FROM [SynapseDataLake].[Files].[synapse]
WHERE name LIKE '%.parquet'

-- List all files in synapse container
SELECT path, name, size, modified_date
FROM [SynapseDataLake].[Files]
WHERE path LIKE '%synapse%'
ORDER BY size DESC

-- Explore machine learning artifacts
SELECT * FROM [SynapseDataLake].[Files].[ml]
WHERE name LIKE '%.pkl' OR name LIKE '%.model'
```

### **Python/Spark Notebooks**
```python
# Initialize Spark session for data exploration
from pyspark.sql import SparkSession
spark = SparkSession.builder.appName("DataExploration").getOrCreate()

# Read from OneLake shortcuts
synapse_df = spark.read.option("recursiveFileLookup", "true") \
    .option("pathGlobFilter", "*.parquet") \
    .parquet("Files/synapse/")

# Display data structure
synapse_df.printSchema()
synapse_df.show(20)
```

### **System Maintenance**
```powershell
# Neural Dream cognitive health check
. .\scripts\neural-dream.ps1; dream --health-check

# Network optimization
. .\scripts\neural-dream.ps1; dream --network-optimization

# Environment setup verification
.\setup-environment.ps1 -VerifyOnly
```

---

## � **System Configuration**

### **Authentication & Permissions**
- **User**: fabioc@microsoft.com
- **Tenant**: Microsoft (MSIT environment)
- **Azure Subscription**: Lab Subscription (f6ab5f6d-606a-4256-aba7-1feeeb53784f)
- **Storage Role**: Storage Blob Data Reader on cpestaginglake
- **Fabric Access**: Member/Admin of Fishbowl_POC workspace

### **Key Resource IDs**
```yaml
Subscription: f6ab5f6d-606a-4256-aba7-1feeeb53784f
Resource Group: integration
Storage Account: cpestaginglake
Synapse Workspace: cpesynapse
Fabric Workspace: 1dfcfdc6-64ff-4338-8eec-2676ff0f5884
Fabric Environment: MSIT (msit.powerbi.com.mcas.ms)
```

### **Environment File Configuration**
The project now uses a `.env` file for configuration management:
```bash
# Core configuration in .env file
FABRIC_WORKSPACE_ID=1dfcfdc6-64ff-4338-8eec-2676ff0f5884
STORAGE_ACCOUNT_NAME=cpestaginglake
DATA_FORMAT=PARQUET
TABLE_PREFIX=staging_
USE_WORKSPACE_ID=true

# Full configuration available in .env.template
```

---

## 📊 **Data Analysis Quick Start**

### **1. Access Your Data (2 minutes)**
1. Go to https://msit.powerbi.com.mcas.ms/
2. Click "Fishbowl_POC" workspace
3. Open "SynapseDataLake" lakehouse
4. Navigate to "Files" section
5. Browse `/synapse` folder for main datasets

### **2. Quick Data Preview (5 minutes)**
1. Click on any `.parquet` or `.csv` file
2. Use "Preview" to see data structure
3. Note interesting columns and data patterns
4. Document file sizes and organization

### **3. SQL Analysis (10 minutes)**
1. Go to lakehouse → "SQL Analytics endpoint"
2. Run sample queries (see Quick Access Commands above)
3. Explore data relationships and quality
4. Test query performance

### **4. Notebook Analysis (15 minutes)**
1. Create new Notebook in workspace
2. Use Python/Spark code samples above
3. Load and analyze your datasets
4. Create visualizations and insights

---

## � **Troubleshooting Quick Fixes**

### **Access Issues**
```powershell
# Re-authenticate Azure CLI
az login --use-device-code

# Check storage permissions
az role assignment list --assignee $(az ad signed-in-user show --query objectId -o tsv) --scope "/subscriptions/f6ab5f6d-606a-4256-aba7-1feeeb53784f/resourceGroups/integration/providers/Microsoft.Storage/storageAccounts/cpestaginglake"

# Verify Fabric workspace access
# If access denied, contact workspace admin or IT support
```

### **Performance Issues**
```sql
-- Check file sizes and organization
SELECT path, COUNT(*) as file_count, SUM(size) as total_size
FROM [SynapseDataLake].[Files]
GROUP BY path
ORDER BY total_size DESC

-- Identify large files that might need optimization
SELECT TOP 20 path, name, size
FROM [SynapseDataLake].[Files]
WHERE size > 100000000  -- Files larger than 100MB
ORDER BY size DESC
```

---

## 📋 **Key Contacts & Resources**

### **Documentation**
- **Architecture Guide**: [ARCHITECTURE.md](ARCHITECTURE.md)
- **Integration Guide**: [MSIT-FABRIC-INTEGRATION-GUIDE.md](MSIT-FABRIC-INTEGRATION-GUIDE.md)
- **Setup Instructions**: [README.md](README.md)

### **Support Escalation**
- **Azure Issues**: Azure Portal support or IT helpdesk
- **Fabric Issues**: Microsoft Fabric support or workspace admin
- **MSIT Environment**: Contact Microsoft IT support for MCAS proxy issues

---

## 🎯 **Current Priorities**

### **This Week: Data Exploration**
- [ ] Explore `/synapse` container structure and content
- [ ] Document interesting datasets and their purposes
- [ ] Test query performance and data access patterns
- [ ] Create initial data quality assessment

### **Next Week: Analytics Development**
- [ ] Build sample Power BI reports from connected data
- [ ] Develop Python notebooks for data processing
- [ ] Create automated data monitoring workflows
- [ ] Train team members on Fabric interface

### **Month 2: Production Scale**
- [ ] Optimize data access patterns and performance
- [ ] Implement automated data pipelines
- [ ] Create comprehensive user documentation
- [ ] Scale for enterprise analytics workloads

---

**Quick Reference Version**: 1.0.0 UNNILNILIUM
**Last Updated**: August 7, 2025
**Status**: ✅ **Integration Complete - Data Exploration Phase**
**Environment**: Microsoft IT (MSIT) Production
