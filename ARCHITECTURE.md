# Fishbowl POC - MSIT Enterprise Data Platform Architecture

## Overview

This document describes the enterprise data platform architecture for the Fishbowl Proof of Concept, integrating Azure Synapse Analytics with Microsoft Fabric through OneLake to create a unified analytics platform in the Microsoft IT (MSIT) environment.

**Architecture Version**: 1.0.0 UNNILNILIUM
**Last Updated**: August 7, 2025
**Environment**: Microsoft IT (MSIT) with MCAS proxy
**Status**: ✅ **CONNECTED** - cpestaginglake integrated with Fabric workspace

---

## 🏗️ MSIT Enterprise Data Platform Architecture

```mermaid
graph TB
    %% Data Sources
    subgraph "📊 Data Sources Layer"
        DS1[External Data APIs]
        DS2[Database Systems]
        DS3[File Systems]
        DS4[Streaming Data]
    end

    %% Azure Synapse Layer
    subgraph "☁️ Azure Synapse Analytics (cpesynapse)"
        direction TB
        SWS[Synapse Workspace]
        POOL[SQL Pools<br/>Dedicated/Serverless]
        SPARK[Spark Pools<br/>Data Processing]
        PIPE[Synapse Pipelines<br/>ETL/ELT]
    end

    %% Storage Layer
    subgraph "💾 Azure Data Lake Storage Gen2 (cpestaginglake)"
        direction TB
        ADLS[Storage Account]
        CONT1[📁 synapse<br/>ETL Data]
        CONT2[📁 machinelearning<br/>ML Artifacts]
        CONT3[📁 aas-container<br/>Analysis Services]
        CONT4[📁 test<br/>Test Data]
    end

    %% Microsoft Fabric Layer
    subgraph "🏢 Microsoft Fabric (MSIT)"
        direction TB
        FWS[Fishbowl_POC Workspace<br/>ID: 1dfcfdc6-64ff-4338-8eec-2676ff0f5884]
        LH[SynapseDataLake<br/>Lakehouse]
        SHORTCUTS[OneLake Shortcuts]
        SPARK_F[Fabric Spark<br/>Data Engineering]
        DW_F[Fabric Data Warehouse<br/>SQL Analytics]
        REPORTS[Power BI Reports<br/>Analytics & Dashboards]
    end

    %% Security & Governance
    subgraph "🔐 Security & Governance"
        direction TB
        AAD[Azure Active Directory<br/>fabioc@microsoft.com]
        RBAC[RBAC Permissions<br/>Storage Blob Data Reader]
        MCAS[MCAS Proxy<br/>Cloud App Security]
        AUDIT[Audit Logging<br/>Azure Monitor]
    end

    %% Data Flow Connections
    DS1 --> PIPE
    DS2 --> PIPE
    DS3 --> PIPE
    DS4 --> PIPE

    PIPE --> ADLS
    SWS --> ADLS
    POOL --> ADLS
    SPARK --> ADLS

    ADLS --> CONT1
    ADLS --> CONT2
    ADLS --> CONT3
    ADLS --> CONT4

    CONT1 -.-> SHORTCUTS
    CONT2 -.-> SHORTCUTS
    CONT3 -.-> SHORTCUTS
    CONT4 -.-> SHORTCUTS

    SHORTCUTS -.-> LH
    LH --> SPARK_F
    LH --> DW_F
    LH --> REPORTS

    AAD --> SWS
    AAD --> FWS
    RBAC --> ADLS
    MCAS --> FWS
    AUDIT --> SWS
    AUDIT --> FWS

    %% Styling
    classDef azureService fill:#0078d4,stroke:#004578,stroke-width:2px,color:#fff
    classDef fabricService fill:#ff6b35,stroke:#cc5529,stroke-width:2px,color:#fff
    classDef storage fill:#00bcf2,stroke:#0099cc,stroke-width:2px,color:#fff
    classDef security fill:#7cb342,stroke:#5a8f30,stroke-width:2px,color:#fff

    class SWS,POOL,SPARK,PIPE azureService
    class FWS,LH,SHORTCUTS,SPARK_F,DW_F,REPORTS fabricService
    class ADLS,CONT1,CONT2,CONT3,CONT4 storage
    class AAD,RBAC,MCAS,AUDIT security
```

---

## 🔧 Component Architecture

### Azure Synapse Analytics Layer

The Azure Synapse Analytics workspace `cpesynapse` provides comprehensive data processing capabilities:

- **SQL Pools**: Dedicated and serverless SQL compute for data warehousing
- **Spark Pools**: Auto-scaling distributed computing for big data processing
- **Synapse Pipelines**: ETL/ELT orchestration and data movement
- **Integration Runtime**: Hybrid connectivity and security management

### Microsoft Fabric Integration Layer

The Microsoft Fabric `Fishbowl_POC` workspace enables unified analytics:

- **Lakehouse**: SynapseDataLake with OneLake shortcuts to Synapse storage
- **Data Warehouse**: SQL analytics and T-SQL query capabilities
- **Power BI**: Integrated reporting and dashboard creation
- **Data Engineering**: Fabric Spark notebooks and data flows

**Key Features**:
- Unified data platform combining data engineering and analytics
- Seamless integration with Azure Data Lake Storage Gen2
- Enterprise security and compliance capabilities
- Scalable compute resources for varying workloads

**Integration Benefits**:
- Real-time access to Synapse data through OneLake shortcuts
- Unified analytics across structured and unstructured data
- Self-service BI capabilities for business users
- Enterprise governance and security compliance
**Microsoft Fabric Workspace Structure:**

| Component | Purpose | Key Features |
|-----------|---------|--------------|
| **Lakehouse**: SynapseDataLake | Central data storage | • OneLake shortcuts<br/>• Delta table format<br/>• Real-time sync |
| **Data Warehouse** | SQL analytics platform | • T-SQL queries<br/>• Views and procedures<br/>• Enterprise analytics |
| **Power BI** | Business intelligence | • Interactive reports<br/>• Real-time dashboards<br/>• Self-service BI |
| **Data Engineering** | Processing and transformation | • Spark notebooks<br/>• Data flows<br/>• Pipeline orchestration |

**Workspace Details:**
- **Environment**: MSIT (https://msit.powerbi.com.mcas.ms/)
- **Workspace ID**: 1dfcfdc6-64ff-4338-8eec-2676ff0f5884
- **Capacity**: F64 (Microsoft Fabric)

---

## 📊 Data Flow Architecture

### ETL/ELT Data Pipeline Flow

```mermaid
sequenceDiagram
    participant Sources as Data Sources
    participant Synapse as Synapse Analytics
    participant Storage as ADLS Gen2
    participant Fabric as Microsoft Fabric
    participant Users as End Users

    Note over Sources,Users: Data Ingestion & Processing Flow

    Sources->>Synapse: 1. Raw data ingestion
    Note right of Synapse: ETL Processing
    Synapse->>Synapse: 2. Data transformation
    Synapse->>Storage: 3. Processed data storage

    Note over Storage: Data Lake Structure
    Storage->>Storage: 4. Data organization
    Note right of Storage: /synapse/<br/>/machinelearning/<br/>/aas-container/<br/>/test/

    Storage->>Fabric: 5. OneLake shortcuts
    Note right of Fabric: Real-time access
    Fabric->>Fabric: 6. Further processing
    Note right of Fabric: Fabric Spark<br/>Data Warehousing

    Fabric->>Users: 7. Analytics & Reports
    Note right of Users: Power BI<br/>Self-service analytics
```

### Storage Container Architecture

**cpestaginglake (ADLS Gen2) Container Structure:**

| Container | Priority | Purpose | Subfolders |
|-----------|----------|---------|------------|
| **📁 synapse** | **HIGH** | Synapse workspace artifacts | workspace/, pipelines/, processed/, staging/ |
| **📁 machinelearning** | Medium | ML models and experiments | models/, experiments/, datasets/, artifacts/ |
| **📁 aas-container** | Medium | Analysis Services data | cubes/, tabular/, reports/ |
| **📁 test** | Low | Test and validation data | samples/, validation/, scenarios/ |

**Integration Strategy:**
- **Phase 1**: Start with synapse container (main ETL data)
- **Phase 2**: Add machinelearning container (ML artifacts)
- **Phase 3**: Include aas-container and test containers as needed

---

## 🔐 Security Architecture

### Authentication & Authorization Flow

```mermaid
graph LR
    subgraph "Identity & Access Management"
        User[fabioc@microsoft.com]
        AAD[Azure Active Directory<br/>Tenant: 72f988bf-86f1-41af-91ab-2d7cd011db47]
        RBAC[RBAC Roles]
    end

    subgraph "Security Proxies"
        MCAS[Microsoft Cloud App Security<br/>mcas.ms proxy]
    end

    subgraph "Azure Resources"
        Storage[cpestaginglake<br/>Storage Account]
        Synapse[cpesynapse<br/>Synapse Workspace]
    end

    subgraph "Microsoft Fabric"
        Fabric[MSIT Fabric<br/>Fishbowl_POC Workspace]
    end

    User --> AAD
    AAD --> RBAC
    RBAC --> Storage
    RBAC --> Synapse

    User --> MCAS
    MCAS --> Fabric
    AAD --> Fabric

    Storage --> Fabric
```

### Security Controls Matrix

| Component | Authentication | Authorization | Data Protection | Monitoring |
|-----------|---------------|---------------|----------------|------------|
| **Azure Synapse** | Azure AD | RBAC | Encryption at rest/transit | Azure Monitor |
| **ADLS Gen2** | Azure AD | RBAC + ACLs | Customer-managed keys | Diagnostic logs |
| **Microsoft Fabric** | Azure AD + MCAS | Workspace roles | OneLake encryption | Fabric monitoring |
| **Network** | Private endpoints | NSG rules | VNet integration | Network Watcher |

---

## 🚀 Integration Architecture

### OneLake Shortcut Integration

**Microsoft Fabric Lakehouse: SynapseDataLake Structure**

**Files Section (OneLake Shortcuts):**
- **🔗 synapse/** → `https://cpestaginglake.dfs.core.windows.net/synapse`
  - workspace/ → Live data from Synapse workspace
  - pipelines/ → ETL pipeline outputs
  - processed/ → Transformed datasets

- **🔗 ml/** → `https://cpestaginglake.dfs.core.windows.net/machinelearning`
  - models/ → ML model artifacts
  - experiments/ → Experiment results

- **🔗 aas/** → `https://cpestaginglake.dfs.core.windows.net/aas-container`
  - cubes/ → Analysis Services data

- **🔗 test/** → `https://cpestaginglake.dfs.core.windows.net/test`
  - samples/ → Test datasets

**Tables Section (Delta Lake format):**
- **📊 synapse_summary** → Curated views of synapse data
- **📊 ml_results** → ML model results
- **📊 performance_kpis** → Performance metrics

*🔗 = OneLake Shortcut (real-time link) | 📊 = Delta Table (managed by Fabric)*

### API Integration Points

**Integration Layer Components:**

| API Type | Synapse APIs | Fabric APIs |
|----------|--------------|-------------|
| **REST API** | Workspace management, Pipeline control, Data access | Workspace management, Lakehouse operations, Item management |
| **Authentication** | Azure AD integrated | Azure AD + MCAS proxy |
| **Use Cases** | ETL orchestration, Data processing | Analytics, Reporting, Self-service BI |

**PowerShell/CLI Integration:**
- **Azure Resource Manager**: ARM templates, Resource management, Deployment automation
- **Azure PowerShell**: Automation scripting, Management operations, Configuration updates

---

## 🏛️ Data Governance Architecture

### Data Lineage & Cataloging

**Microsoft Fabric Data Governance Features:**

| Governance Component | Capability | Implementation |
|---------------------|------------|----------------|
| **Data Lineage** | End-to-end data flow tracking | • Automatic lineage from Synapse to Fabric<br/>• Visual dependency mapping<br/>• Impact analysis for changes |
| **Data Catalog** | Unified data discovery | • OneLake metadata catalog<br/>• Searchable data assets<br/>• Business glossary integration |
| **Data Quality** | Automated quality monitoring | • Data profiling and validation<br/>• Quality scorecards<br/>• Anomaly detection |
| **Compliance** | Regulatory adherence | • Data classification<br/>• Retention policies<br/>• Audit trail maintenance |

### Data Classification & Sensitivity

```mermaid
graph TB
    subgraph "🏷️ Data Classification Hierarchy"
        direction TB
        PUBLIC[Public Data<br/>📗 Unrestricted]
        INTERNAL[Internal Data<br/>📘 Business Use]
        CONF[Confidential Data<br/>📙 Restricted Access]
        SECRET[Highly Confidential<br/>📕 Need-to-Know Only]
    end

    subgraph "🔍 Classification Engine"
        direction TB
        SCANNER[Data Scanner<br/>Pattern Recognition]
        LABELS[Sensitivity Labels<br/>Microsoft Purview]
        POLICIES[DLP Policies<br/>Data Loss Prevention]
    end

    subgraph "🛡️ Protection Controls"
        direction TB
        ENCRYPT[Data Encryption<br/>At Rest & Transit]
        ACCESS[Access Controls<br/>RBAC + Conditional Access]
        MONITOR[Activity Monitoring<br/>Audit & Alerts]
    end

    SCANNER --> LABELS
    LABELS --> POLICIES
    POLICIES --> ENCRYPT
    POLICIES --> ACCESS
    POLICIES --> MONITOR

    PUBLIC --> SCANNER
    INTERNAL --> SCANNER
    CONF --> SCANNER
    SECRET --> SCANNER
```

---

## 📈 Performance Architecture

### Data Processing Tiers

**Performance Optimization Strategy**

| Processing Tier | Response Time | Use Cases | Technology Stack |
|----------------|---------------|-----------|------------------|
| **Tier 1: Real-time** | < 1 second | • OneLake shortcuts<br/>• Direct queries<br/>• Interactive dashboards | • Fabric SQL endpoint<br/>• Direct shortcut access<br/>• Power BI DirectQuery |
| **Tier 2: Batch Processing** | Minutes to hours | • Pipeline orchestration<br/>• Data transformations<br/>• Delta table creation | • Synapse pipelines<br/>• Fabric Spark notebooks<br/>• Delta Lake format |
| **Tier 3: Analytical** | Hours to days | • Complex analytics<br/>• ML model training<br/>• Data warehousing | • Advanced analytics<br/>• Machine learning<br/>• Large-scale ETL |

### Monitoring & Observability

**Comprehensive Monitoring Strategy**

```mermaid
graph TB
    subgraph "📊 Monitoring Layers"
        direction TB
        INFRA[Infrastructure Monitoring<br/>Azure Monitor]
        APP[Application Performance<br/>Application Insights]
        DATA[Data Pipeline Monitoring<br/>Synapse & Fabric Metrics]
        USER[User Experience<br/>Power BI Usage Analytics]
    end

    subgraph "🚨 Alerting & Response"
        direction TB
        ALERTS[Alert Rules<br/>Proactive Monitoring]
        ONCALL[On-Call Response<br/>Incident Management]
        AUTO[Auto-remediation<br/>Runbook Automation]
    end

    subgraph "📈 Analytics & Insights"
        direction TB
        DASH[Monitoring Dashboards<br/>Real-time Views]
        REPORTS[Performance Reports<br/>Historical Analysis]
        TRENDS[Trend Analysis<br/>Capacity Planning]
    end

    INFRA --> ALERTS
    APP --> ALERTS
    DATA --> ALERTS
    USER --> ALERTS

    ALERTS --> ONCALL
    ALERTS --> AUTO

    INFRA --> DASH
    APP --> DASH
    DATA --> DASH
    USER --> DASH

    DASH --> REPORTS
    REPORTS --> TRENDS
```

**Key Performance Indicators (KPIs):**

| Category | Metric | Target | Monitoring Tool |
|----------|--------|--------|-----------------|
| **Availability** | System uptime | 99.9% | Azure Monitor |
| **Performance** | Query response time | < 5 seconds | Fabric Analytics |
| **Data Quality** | Pipeline success rate | 99.5% | Synapse Monitoring |
| **Cost** | Monthly spend variance | ± 10% | Azure Cost Management |
| **Security** | Failed authentications | < 0.1% | Azure AD Logs |
| **Usage** | Active user sessions | Trending up | Power BI Analytics |

---

## 🔄 Deployment Architecture

### Environment Topology

```mermaid
graph TB
    subgraph "Azure Subscription: Lab Subscription"
        subgraph "Resource Group: integration"
            Storage[cpestaginglake<br/>Storage Account]
            Synapse[cpesynapse<br/>Synapse Workspace]
        end

        subgraph "Networking"
            VNet[Virtual Network]
            PrivateEndpoint[Private Endpoints]
            NSG[Network Security Groups]
        end
    end

    subgraph "Microsoft Fabric (MSIT Tenant)"
        subgraph "Fabric Capacity: F64"
            Workspace[Fishbowl_POC<br/>Workspace]
            Lakehouse[SynapseDataLake<br/>Lakehouse]
        end
    end

    subgraph "Management & Operations"
        Monitor[Azure Monitor]
        Alerts[Alert Rules]
        Logs[Log Analytics]
        Backup[Backup Policies]
    end

    Storage --> PrivateEndpoint
    Synapse --> VNet
    VNet --> NSG

    Storage -.-> Lakehouse
    Synapse --> Storage

    Storage --> Monitor
    Synapse --> Monitor
    Workspace --> Logs
```

### Infrastructure as Code

**Infrastructure Deployment Stack**

| Component Category | Files | Purpose |
|-------------------|-------|---------|
| **ARM Templates / Bicep** | • main.bicep<br/>• storage.bicep<br/>• synapse.bicep<br/>• networking.bicep | • Core resource deployment<br/>• ADLS Gen2 configuration<br/>• Synapse workspace setup<br/>• VNet and private endpoints |
| **PowerShell Automation** | • setup-environment.ps1<br/>• grant-fabric-storage-permissions.ps1<br/>• msit-fabric-verify.ps1<br/>• neural-dream.ps1 | • Environment setup<br/>• RBAC permissions<br/>• MSIT validation<br/>• Cognitive maintenance |
| **Configuration Management** | • cognitive-config.json<br/>• synapse-fabric-connection.json<br/>• azure.yaml | • System configuration<br/>• Integration settings<br/>• AZD deployment specs |

---

## 📋 Architecture Validation Checklist

### ✅ Infrastructure Readiness
- [x] **Azure Subscription**: Lab Subscription (f6ab5f6d-606a-4256-aba7-1feeeb53784f)
- [x] **Storage Account**: cpestaginglake configured with enterprise security
- [x] **Synapse Workspace**: cpesynapse with linked storage
- [x] **Network Security**: Private endpoints and RBAC configured
- [x] **Authentication**: Azure AD integration verified

### ✅ Fabric Integration Status
- [x] **Workspace Access**: Fishbowl_POC workspace accessible
- [x] **Storage Permissions**: Storage Blob Data Reader role assigned
- [x] **Container Discovery**: 4 containers identified and documented
- [x] **Authentication**: MSIT environment with MCAS proxy configured
- [x] **OneLake Shortcuts**: ✅ **CONNECTED** - cpestaginglake successfully integrated

### ⏳ Deployment Pipeline
- [x] **Scripts Created**: All automation scripts developed and tested
- [x] **Documentation**: Comprehensive guides and references created
- [x] **Validation**: Verification scripts confirm readiness
- [x] **Integration Testing**: ✅ **COMPLETE** - cpestaginglake connected to Fabric
- [ ] **User Training**: Ready to begin with live environment

---

## 🔮 Future Architecture Enhancements

### Phase 2: Advanced Analytics & AI Integration

**Timeline: Q2-Q3 2025**

| Enhancement Area | Capability | Technology Stack | Business Value |
|-----------------|------------|------------------|----------------|
| **Machine Learning** | Automated ML pipelines | • Azure ML integration<br/>• Fabric Data Science<br/>• MLOps automation | • Predictive analytics<br/>• Intelligent insights<br/>• Automated decision support |
| **Real-time Analytics** | Event streaming integration | • Azure Event Hubs<br/>• Stream Analytics<br/>• Real-time KQL queries | • Live dashboards<br/>• Immediate alerting<br/>• Real-time personalization |
| **Advanced AI** | Generative AI integration | • Azure OpenAI Service<br/>• Cognitive Services<br/>• Custom AI models | • Natural language querying<br/>• Automated report generation<br/>• Intelligent data exploration |

### Phase 3: Enterprise Scale & Governance

**Timeline: Q4 2025 - Q1 2026**

```mermaid
graph LR
    subgraph "🌍 Global Distribution"
        MULTI[Multi-region Deployment]
        DR[Disaster Recovery]
        GEO[Geo-redundancy]
    end

    subgraph "🏛️ Enterprise Governance"
        MESH[Data Mesh Architecture]
        CATALOG[Enterprise Data Catalog]
        LINEAGE[End-to-end Lineage]
    end

    subgraph "💰 Cost Optimization"
        AUTO_SCALE[Auto-scaling]
        USAGE_OPT[Usage Optimization]
        COST_ALERTS[Cost Monitoring]
    end

    subgraph "🛡️ Zero Trust Security"
        IDENTITY[Identity Protection]
        NETWORK[Network Security]
        DATA_PROTECT[Data Protection]
    end

    MULTI --> DR
    DR --> GEO

    MESH --> CATALOG
    CATALOG --> LINEAGE

    AUTO_SCALE --> USAGE_OPT
    USAGE_OPT --> COST_ALERTS

    IDENTITY --> NETWORK
    NETWORK --> DATA_PROTECT
```

**Advanced Features Roadmap:**

| Quarter | Feature Category | Key Deliverables |
|---------|------------------|------------------|
| **Q2 2025** | AI/ML Integration | • Automated ML pipelines<br/>• Predictive analytics<br/>• AI-powered insights |
| **Q3 2025** | Real-time Processing | • Event streaming<br/>• Live analytics<br/>• Real-time alerts |
| **Q4 2025** | Global Scale | • Multi-region deployment<br/>• Disaster recovery<br/>• Global data distribution |
| **Q1 2026** | Enterprise Governance | • Data mesh implementation<br/>• Advanced compliance<br/>• Zero Trust security |

### Technology Evolution Strategy

**Emerging Technology Integration:**

- **Quantum Computing**: Future quantum-safe encryption and quantum ML algorithms
- **Edge Computing**: IoT data processing at the edge with Azure IoT Edge
- **Blockchain**: Data lineage and provenance tracking using blockchain technology
- **Extended Reality (XR)**: Immersive data visualization and collaboration tools

---

**Architecture Documentation Version**: 1.0.0 UNNILNILIUM
**Created**: August 7, 2025
**Status**: ✅ **INTEGRATION COMPLETE** - cpestaginglake successfully connected to Fabric
**Next Review**: Performance optimization and user training

*This architecture represents a sophisticated enterprise data platform successfully integrating Azure Synapse Analytics with Microsoft Fabric through secure OneLake shortcuts, enabling unified analytics capabilities across the organization.*
