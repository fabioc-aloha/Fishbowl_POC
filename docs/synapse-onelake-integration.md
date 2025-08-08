# Azure Synapse to OneLake Integration Configuration
# Date: August 7, 2025
# Workspace: cpesynapse

## 🔗 Connection Details

### Synapse Workspace: cpesynapse
- **Dedicated SQL Endpoint**: `cpesynapse.sql.azuresynapse.net`
- **Serverless SQL Endpoint**: `cpesynapse-ondemand.sql.azuresynapse.net`
- **Web Interface**: https://web.azuresynapse.net?workspace=...
- **Development Endpoint**: https://cpesynapse.dev.azuresynapse.net
- **Location**: East US
- **Resource Group**: Integration
- **Admin**: fabioc (you)

### Spark Pools Available:
1. **CCI34** - XLarge nodes, Spark 3.4, Memory-optimized
2. **ETLProd** - XLarge nodes, Spark 3.4, Memory-optimized
3. **XODOLarge35** - Large nodes, Spark 3.5, Memory-optimized

### Data Lake Storage:
- **Account URL**: https://cpedatalake.dfs.core.windows.net
- **File System**: edlp

## 🏗️ OneLake Integration Endpoints

### FishbowlOneLake Lakehouse:
- **Workspace ID**: 66c04c50-bc7a-4175-b91e-9d0164ca294a
- **Lakehouse ID**: e178728a-418c-4cb7-b7ef-44ce84223239
- **Files Path**: https://msit-onelake.dfs.fabric.microsoft.com/66c04c50-bc7a-4175-b91e-9d0164ca294a/e178728a-418c-4cb7-b7ef-44ce84223239/Files
- **Tables Path**: https://msit-onelake.dfs.fabric.microsoft.com/66c04c50-bc7a-4175-b91e-9d0164ca294a/e178728a-418c-4cb7-b7ef-44ce84223239/Tables
- **SQL Endpoint**: x6eps4xrq2xudenlfv6naeo3i4-kbgmazt2xr2udoi6tuawjsrjji.msit-datawarehouse.fabric.microsoft.com

## 🚀 Integration Patterns

### 1. Data Migration from Synapse to OneLake
```sql
-- Use CETAS (Create External Table As Select) to move data
CREATE EXTERNAL TABLE [OneLakeDestination]
WITH (
    LOCATION = 'https://msit-onelake.dfs.fabric.microsoft.com/66c04c50-bc7a-4175-b91e-9d0164ca294a/e178728a-418c-4cb7-b7ef-44ce84223239/Tables/YourTable/',
    DATA_SOURCE = OneLakeDataSource,
    FILE_FORMAT = DeltaFormat
)
AS SELECT * FROM [YourSynapseTable];
```

### 2. Real-time Data Sync
- Use Synapse pipelines to sync data to OneLake
- Set up Change Data Capture (CDC) from Synapse to Fabric EventStreams
- Use Spark pools for large-scale data transformation

### 3. Hybrid Analytics
- Keep historical data in Synapse for complex analytics
- Move frequently accessed data to OneLake for performance
- Use OneLake as the single source of truth for new data

## 🔧 Next Steps

1. **Test Connectivity**: Verify connection between Synapse and OneLake
2. **Data Mapping**: Identify which tables to migrate/sync
3. **Pipeline Creation**: Build data movement pipelines
4. **Performance Optimization**: Configure for optimal data transfer
5. **Security Setup**: Ensure proper authentication and authorization

## 📊 Spark Pool Recommendations

- **ETLProd**: Use for production data transformations
- **CCI34**: Use for analytics and reporting workloads
- **XODOLarge35**: Use for development and testing (latest Spark 3.5)
