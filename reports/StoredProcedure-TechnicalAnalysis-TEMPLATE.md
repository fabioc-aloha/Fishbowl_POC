# PHASE 1: Technical Analysis - [Procedure Name]

## 🛠️ TECHNICAL DATA COLLECTION PHASE

**STRICT SCOPE**: This template is for **TECHNICAL DATA COLLECTION ONLY**
- ✅ **DO**: Extract raw database facts, code, schemas, dependencies
- ❌ **DON'T**: Interpret business meaning, create recommendations, analyze business impact
- ✅ **DO**: Use MCP tools for real-time database queries
- ❌ **DON'T**: Make assumptions about business requirements or purpose

**MANDATORY SEQUENCE**: This MUST be completed before Business Analysis Phase
- **Input**: Database connection and procedure name
- **Process**: Technical data extraction using MCP tools
- **Output**: Complete technical reference for business analysis team

**ROLE SEPARATION**:
- **Technical Analyst**: Extracts facts, documents implementation
- **Business Analyst**: Will interpret this data in Phase 2

---

## 📋 TECHNICAL ANALYST RESPONSIBILITIES

**WHAT YOU MUST DO**:
- Extract ONLY factual data from database using MCP tools
- Document actual code implementation without interpretation
- Record technical specifications, schemas, dependencies
- Validate all data with real-time database queries
- Provide complete technical reference for business team

**WHAT YOU MUST NOT DO**:
- Interpret business purpose or meaning
- Create business requirements or recommendations
- Analyze business impact or strategic value
- Make assumptions about user needs or business processes
- Include any business context or interpretation

**SUCCESS CRITERIA**:
- All data extracted from live database (no assumptions)
- Complete technical documentation ready for business analysis
- Zero business interpretation or recommendations
- Technical facts validated and verified

---

## 📊 DOCUMENT METADATA

**Procedure Name**: [Enter stored procedure name from database]
**Database**: [Database name from MCP connection]
**Server**: [Server name from MCP connection]
**Analysis Date**: [Current date]
**Technical Analyst**: [Your name/role]
**Connection ID**: [MCP connection ID used]
**Template Version**: 1.0.0
**Phase**: Technical Data Collection (Phase 1 of 2)
**Next Phase**: Business Analysis (requires this document as input)

---

## 1️⃣ SOURCE CODE EXTRACTION (Technical Facts Only)

### Raw Procedure Source Code
```sql
-- MCP Query: SELECT OBJECT_DEFINITION(OBJECT_ID('[ProcedureName]'))
-- TECHNICAL EXTRACTION ONLY - NO BUSINESS INTERPRETATION
[Insert complete procedure source code here]
```

### Technical Code Metrics
- **Total Lines**: [Count from source - factual count only]
- **Executable Statements**: [Count SQL statements - no analysis]
- **Comment Lines**: [Count comment lines - factual count only]
- **Branching Statements**: [Count IF/CASE statements - factual count only]

---

## 2️⃣ PARAMETER SPECIFICATION (Database Schema Facts)

### Technical Parameter Extraction
```sql
-- MCP Query: SELECT * FROM sys.parameters WHERE object_id = OBJECT_ID('[ProcedureName]')
-- EXTRACT TECHNICAL SPECIFICATIONS ONLY
[Insert parameter query results - raw data only]
```

### Parameter Technical Specifications
| Parameter Name | Data Type | Max Length | Default Value | Is Output | Is Nullable |
|----------------|-----------|------------|---------------|-----------|-------------|
| [Extract each parameter specification - technical facts only] |

---

## 3. Dependency Analysis

### Direct Object Dependencies
```sql
-- Extract using: SELECT * FROM sys.sql_expression_dependencies WHERE referencing_id = OBJECT_ID('[ProcedureName]')
[Insert dependency query results]
```

### Referenced Tables
| Schema | Table Name | Dependency Type | Usage Context |
|--------|------------|-----------------|---------------|
| [List all tables with their exact usage] |

### Referenced Views
| Schema | View Name | Dependency Type | Usage Context |
|--------|-----------|-----------------|---------------|
| [List all views with their exact usage] |

### Referenced Procedures
| Schema | Procedure Name | Call Context | Parameters Passed |
|--------|----------------|--------------|-------------------|
| [List all procedure calls with context] |

### Referenced Functions
| Schema | Function Name | Return Type | Usage Context |
|--------|---------------|-------------|---------------|
| [List all function calls with context] |

---

## 4. Table Schema Details

### [Table Name 1] Schema
```sql
-- Extract using: SELECT * FROM information_schema.columns WHERE table_name = '[TableName]'
[Insert complete column definitions]
```

### [Table Name 1] Indexes
```sql
-- Extract using: SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('[TableName]')
[Insert index definitions]
```

### [Table Name 1] Constraints
```sql
-- Extract using: SELECT * FROM information_schema.table_constraints WHERE table_name = '[TableName]'
[Insert constraint definitions]
```

*[Repeat for each referenced table]*

---

## 5. View Source Code

### [View Name 1] Definition
```sql
-- Extract using: SELECT OBJECT_DEFINITION(OBJECT_ID('[ViewName]'))
[Insert complete view source code]
```

*[Repeat for each referenced view]*

---

## 6. Related Procedure Source Code

### [Procedure Name 1] Definition
```sql
-- Extract using: SELECT OBJECT_DEFINITION(OBJECT_ID('[ProcedureName]'))
[Insert complete procedure source code]
```

*[Repeat for each referenced procedure]*

---

## 7. Function Source Code

### [Function Name 1] Definition
```sql
-- Extract using: SELECT OBJECT_DEFINITION(OBJECT_ID('[FunctionName]'))
[Insert complete function source code]
```

*[Repeat for each referenced function]*

---

## 8. System Catalog Analysis

### Object Information
```sql
-- Extract using: SELECT * FROM sys.objects WHERE name = '[ProcedureName]'
[Insert object metadata]
```

### Permission Analysis
```sql
-- Extract using: SELECT * FROM sys.database_permissions WHERE major_id = OBJECT_ID('[ProcedureName]')
[Insert permission details]
```

### Execution Statistics (if available)
```sql
-- Extract using: SELECT * FROM sys.dm_exec_procedure_stats WHERE object_id = OBJECT_ID('[ProcedureName]')
[Insert execution statistics]
```

---

## 9. Data Flow Mapping

### Input Data Sources
| Source Type | Object Name | Columns Used | Filter Conditions |
|-------------|-------------|--------------|-------------------|
| [Map each data input with technical details] |

### Output Data Targets
| Target Type | Object Name | Columns Modified | Operation Type |
|-------------|-------------|------------------|----------------|
| [Map each data output with technical details] |

### Intermediate Processing
| Step | Operation | Objects Involved | Technical Details |
|------|-----------|------------------|-------------------|
| [Document each processing step] |

---

## 10. Error Handling Analysis

### Try-Catch Blocks
```sql
[Extract all error handling code blocks]
```

### Error Messages
| Error Condition | Error Message | Error Code | Handling Method |
|-----------------|---------------|------------|-----------------|
| [Document all error scenarios] |

### Transaction Management
```sql
[Extract all transaction control statements]
```

---

## 11. Performance Characteristics

### Query Execution Plans (if available)
```sql
-- Use: SET SHOWPLAN_XML ON before procedure analysis
[Insert execution plan analysis]
```

### Index Usage Analysis
| Table | Index Used | Seek/Scan | Estimated Rows |
|-------|------------|-----------|----------------|
| [Document index usage patterns] |

### Resource Consumption
- **Estimated CPU Cost**: [If available from execution plan]
- **Estimated I/O Cost**: [If available from execution plan]
- **Memory Requirements**: [If available from execution plan]

---

## 12. Security Analysis

### Permissions Required
```sql
-- Extract using: SELECT * FROM fn_my_permissions('[ProcedureName]', 'OBJECT')
[Insert permission requirements]
```

### SQL Injection Vulnerabilities
| Parameter | Risk Level | Vulnerability Type | Mitigation Present |
|-----------|------------|--------------------|--------------------|
| [Analyze each parameter for injection risks] |

### Dynamic SQL Analysis
```sql
[Extract all dynamic SQL construction code]
```

---

## 13. Configuration Dependencies

### System Configuration
```sql
-- Extract relevant configuration settings
[Insert configuration dependencies]
```

### Database Settings
```sql
-- Extract database-specific settings that affect procedure
[Insert database configuration]
```

### Linked Server Dependencies
```sql
-- Extract any linked server references
[Insert linked server usage]
```

---

## ✅ TECHNICAL ANALYSIS COMPLETION CHECKLIST

**Phase 1 Technical Data Collection Validation**:
- [ ] Database connection established using `mssql_connect`
- [ ] Connection details verified using `mssql_get_connection_details`
- [ ] Target procedure exists verified using `mssql_list_*` commands
- [ ] Procedure source code extracted using `OBJECT_DEFINITION`
- [ ] All referenced object source codes extracted
- [ ] All table schemas extracted using `information_schema.columns`
- [ ] All index definitions extracted using `sys.indexes`
- [ ] All constraint definitions extracted using catalog views
- [ ] Direct dependencies extracted using `sys.sql_expression_dependencies`
- [ ] Indirect dependencies identified through code analysis
- [ ] Object metadata extracted using `sys.objects`
- [ ] Parameter definitions extracted using `sys.parameters`
- [ ] Permission analysis completed using `sys.database_permissions`

**Quality Assurance - Technical Facts Only**:
- [ ] All SQL queries executed successfully against live database
- [ ] No placeholder data remains in document
- [ ] All technical specifications verified with real-time MCP queries
- [ ] Query execution timestamps documented for data freshness
- [ ] Zero business interpretation or analysis included
- [ ] Document contains only factual technical data

---

## 🔄 HANDOFF TO BUSINESS ANALYSIS PHASE

**TECHNICAL ANALYSIS COMPLETE** ✅
- **Save this document as**: `[ProcedureName]-TechnicalAnalysis.md`
- **Status**: Ready for Business Analysis Phase (Phase 2)
- **Next Template**: `StoredProcedure-BusinessAnalysis-TEMPLATE.md`

**CRITICAL HANDOFF REQUIREMENTS**:
1. **Business Analyst** must use this document as PRIMARY INPUT for Phase 2
2. **All business interpretation** happens in Phase 2 - NOT in this document
3. **Technical data completeness** validated before Phase 2 begins
4. **No modifications** to technical facts during business analysis

**BUSINESS ANALYSIS TEAM INSTRUCTIONS**:
- Reference this technical analysis as `[ProcedureName]-TechnicalAnalysis.md`
- Do NOT modify technical findings - interpret business meaning only
- Use technical facts to reverse-engineer business requirements
- Create executive summaries based on technical evidence
- Generate strategic recommendations from technical capabilities

---

**🚫 END OF TECHNICAL ANALYSIS SCOPE**
*Business interpretation, executive summaries, and strategic recommendations belong in Phase 2 Business Analysis only*
