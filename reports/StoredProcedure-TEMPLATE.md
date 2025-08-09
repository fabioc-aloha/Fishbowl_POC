# [Stored Procedure Name] - Comprehensive Dependency Analysis Report

**IMPORTANT FORMATTING RULE**: Do NOT use emojis anywhere in this report.

**Generated**: [Date] at [Time] UTC
**Server**: [Server Name]
**Database**: [Database Name]
**Schema**: [Schema Name]
**Analysis Method**: Real-time MCP SQL Server connection
**Connection ID**: [MCP Connection ID]
**Total Database Tables**: [Number - fetched using mssql_run_query]
**Analyst**: [Your Name]
**Report Purpose**: [Brief description of why this analysis was needed]

**CRITICAL REQUIREMENT**: All data in this report MUST be fetched real-time from the database server using MCP SQL tools. Do not use cached data, documentation, or assumptions.

---

## Executive Summary

> **Section Purp   - Document business purpose for each view based on actual definition
   - Include base table dependencies from real-time analysis

3. **All Function and Stored Procedure Dependencies**:
   - **Direct procedure calls**: Query for procedures called directly:
     ```sql
     SELECT DISTINCT
         OBJECT_SCHEMA_NAME(referenced_id) as SchemaName,
         OBJECT_NAME(referenced_id) as ProcedureName
     FROM sys.sql_expression_dependencies
     WHERE referencing_id = OBJECT_ID('[Schema].[ProcedureName]')
       AND referenced_id IN (SELECT object_id FROM sys.procedures);
     ```
   - **Function dependencies**: Query for functions used:
     ```sql
     SELECT DISTINCT
         OBJECT_SCHEMA_NAME(referenced_id) as SchemaName,
         OBJECT_NAME(referenced_id) as FunctionName
     FROM sys.sql_expression_dependencies
     WHERE referencing_id = OBJECT_ID('[Schema].[ProcedureName]')
       AND referenced_id IN (SELECT object_id FROM sys.objects WHERE type IN ('FN','IF','TF'));
     ```
   - **Extract complete source code** for all dependent procedures and functions
   - **Document indirect dependencies**: Analyze dependencies of dependent procedures
   - Get parameter definitions for all dependent objects using MCP

### Step 6: Complete Dependency Coverage Validation

1. **Comprehensive Dependency Review**:
   - Verify ALL tables (input, output, lookup, configuration) are documented in Appendix A
   - Verify ALL views (direct and indirect) are documented in Appendix B with complete source code
   - Verify ALL functions and procedures are documented in Appendix C with complete source code
   - Cross-reference dependencies to ensure none are missed

2. **Technical Validation**: provides a high-level overview of the stored procedure, its business purpose, complexity assessment, and key dependency metrics. Use this summary to quickly understand the procedure's role in the system and its impact on the overall architecture.

**Instructions for Completion**:
1. **Use MCP Tools Only**: All metrics must be fetched using `mssql_run_query` - no estimates or assumptions
2. Replace [X] and [Y] with actual counts from real-time database queries
3. Choose appropriate complexity level: High (>10 dependencies, complex logic), Medium (5-10 dependencies), Low (<5 dependencies)
4. Assess business impact: Critical (system failure if broken), Important (significant business disruption), Standard (routine operations)
5. Write 1-2 clear paragraphs describing what the procedure actually does based on source code analysis
6. Document how the procedure fits into business processes using actual usage patterns from the database

**Required MCP Queries for Metrics**:
```sql
-- Get total table count
SELECT COUNT(*) as TableCount FROM sys.tables;

-- Get procedure dependency count
SELECT
    COUNT(DISTINCT referenced_entity_name) as DependencyCount
FROM sys.sql_expression_dependencies
WHERE referencing_id = OBJECT_ID('[Schema].[ProcedureName]');

-- Get procedure line count
SELECT LEN(definition) - LEN(REPLACE(definition, CHAR(10), '')) + 1 as LineCount
FROM sys.sql_modules
WHERE object_id = OBJECT_ID('[Schema].[ProcedureName]');
```

[Description of the stored procedure's purpose and functionality]

**Key Metrics:**

- **Primary Dependencies**: [X] database tables + [Y] system objects (use MCP query results)
- **Secondary Dependencies**: [X] views, [Y] stored procedures (use MCP query results)
- **Complexity Score**: [High/Medium/Low] (based on dependency count and code analysis)
- **Business Impact**: [Critical/Important/Standard] (assessed from usage patterns)
- **Lines of Code**: [Number] (from sys.sql_modules via MCP)
- **Last Modified**: [Date from sys.objects.modify_date via MCP]
- **Execution Frequency**: [From sys.dm_exec_procedure_stats via MCP if available]

**Purpose**: [1-2 paragraphs description of what this procedure does]

**Usage**: [Description of how and when this procedure is used in the business process]

---

## Business Requirements (Reverse-Engineered)

> **Section Purpose**: This section extracts and documents the business requirements that have been implemented within the stored procedure code. By reverse-engineering the logic, data flows, and business rules embedded in the implementation, we create a comprehensive Business Requirements Document (BRD) that captures the actual system behavior and business objectives.

**Instructions for Completion**:
1. **Connect to Database**: Use `mssql_connect` to establish real-time connection
2. **Extract Source Code**: Use `mssql_run_query` with `SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('[ProcedureName]')`
3. Read through the stored procedure code completely
4. Identify distinct business functions (use BR-001, BR-002, etc.)
5. For each requirement, document what the code actually does, not what you think it should do
6. **Fetch Configuration Data**: Use MCP queries to get actual parameter values, thresholds, and business rules
7. Remove any BR-00X sections that don't apply to your specific procedure
8. Focus on observable behavior rather than assumed intentions

**Essential MCP Queries for Business Requirements**:
```sql
-- Get procedure parameters and their defaults
SELECT
    parameter_name,
    system_type_name,
    default_value,
    is_output
FROM sys.parameters p
JOIN sys.types t ON p.system_type_id = t.system_type_id
WHERE object_id = OBJECT_ID('[Schema].[ProcedureName]')
ORDER BY parameter_id;

-- Get configuration tables referenced (if any patterns exist)
-- This needs to be customized based on your procedure's logic
```

### BR-001: [Primary Business Function]
**Requirement**: [Main business requirement that the procedure fulfills]
- **[Key Parameter/Rule 1]**: [Description and values]
- **[Key Parameter/Rule 2]**: [Description and values]
- **[Key Parameter/Rule 3]**: [Description and values]
- **Business Justification**: [Why this requirement exists and its business value]

### BR-002: [Data Integration Requirements]
**Requirement**: [How the procedure handles data from multiple sources]
- **[Source 1]**: [Description of first data source and its role]
- **[Source 2]**: [Description of second data source and its role]
- **[Integration Logic]**: [How sources are combined or processed]
- **Business Justification**: [Business value of multi-source integration]

### BR-003: [Data Quality and Validation]
**Requirement**: [Quality controls and validation mechanisms]
- **[Validation Rule 1]**: [Description of first validation rule]
- **[Validation Rule 2]**: [Description of second validation rule]
- **[Error Handling]**: [How errors and exceptions are managed]
- **Business Justification**: [Why data quality is critical for business operations]

### BR-004: [Performance and Scalability]
**Requirement**: [Performance requirements and scaling considerations]
- **[Performance Target 1]**: [Specific performance requirement]
- **[Performance Target 2]**: [Another performance consideration]
- **[Scalability Factor]**: [How the system handles volume increases]
- **Business Justification**: [Business impact of performance requirements]

### BR-005: [Compliance and Audit]
**Requirement**: [Regulatory compliance and audit trail requirements]
- **[Audit Mechanism 1]**: [Description of first audit feature]
- **[Audit Mechanism 2]**: [Description of second audit feature]
- **[Compliance Feature]**: [Specific compliance implementation]
- **Business Justification**: [Regulatory or business need for audit capabilities]

### BR-006: [Business Logic Configuration]
**Requirement**: [Configurable business rules and parameters]
- **[Configuration Source]**: [Where business rules are stored/managed]
- **[Rule Type 1]**: [Description of first configurable rule]
- **[Rule Type 2]**: [Description of second configurable rule]
- **Business Justification**: [Why business rules need to be configurable]

### BR-007: [Additional Requirements]
**Requirement**: [Any additional business requirements discovered]
- **[Requirement Detail 1]**: [Description]
- **[Requirement Detail 2]**: [Description]
- **[Requirement Detail 3]**: [Description]
- **Business Justification**: [Business value and rationale]

> **Template Instructions**:
> 1. Analyze the stored procedure code to identify embedded business logic
> 2. Map code patterns to business requirements (volume targets, validation rules, etc.)
> 3. Document configuration sources (tables, parameters, constants)
> 4. Identify compliance and audit mechanisms
> 5. Extract performance and scalability requirements from implementation
> 6. Reverse-engineer business justifications from the code's behavior
> 7. Use actual values from the database where possible
> 8. Remove unused BR-00X sections if not applicable to your specific procedure

---

## Dependency Diagram

> **Section Purpose**: This diagram provides a visual representation of all database objects that the stored procedure depends on. It shows the relationships between tables, views, other stored procedures, and system objects. Use this diagram to understand the data flow architecture and identify potential impact points for changes.

```mermaid
graph TD
    %% Main Stored Procedure
    SP[sp_[ProcedureName]]

    %% Tables (use rectangle shape)
    T1[Table1]
    T2[Table2]
    T3[Table3]
    %% Add more tables as needed

    %% Views (use rounded rectangle)
    V1(View1)
    V2(View2)
    %% Add more views as needed

    %% Other Stored Procedures (use circle)
    P1((sp_RelatedProc1))
    P2((sp_RelatedProc2))
    %% Add more procedures as needed

    %% System Objects (use diamond)
    SYS1{sys.indexes}
    SYS2{sys.objects}
    SYS3{OBJECT_ID}

    %% Define relationships
    SP --> T1
    SP --> T2
    SP --> T3
    SP --> V1
    SP --> V2
    SP --> P1
    SP --> P2
    SP --> SYS1
    SP --> SYS2
    SP --> SYS3

    %% Styling
    classDef tableStyle fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef viewStyle fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef procStyle fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef systemObj fill:#fff3e0,stroke:#f57f17,stroke-width:2px

    class T1,T2,T3 tableStyle
    class V1,V2 viewStyle
    class P1,P2,SP procStyle
    class SYS1,SYS2,SYS3 systemObj
```

**Dependency Legend:**
- **Tables**: Direct table dependencies (SELECT/INSERT/UPDATE/DELETE)
- **Views**: View dependencies for data access
- **Stored Procedures**: Related procedure calls
- **System Objects**: System catalog usage

---

## Data Flow Analysis

> **Section Purpose**: This section breaks down the stored procedure's execution into logical steps and visualizes the data flow through each phase. The flowchart helps identify the sequence of operations, decision points, and data transformations. Use this analysis to understand the procedure's business logic and identify optimization opportunities.

### Execution Flow

1. **[Step 1 Name]**: [Description of what this step does]
2. **[Step 2 Name]**: [Description of what this step does]
3. **[Step 3 Name]**: [Description of what this step does]
4. **[Step 4 Name]**: [Description of what this step does]
5. **[Step 5 Name]**: [Description of what this step does]
6. **[Step 6 Name]**: [Description of what this step does]

---

## Database Object Dependencies

> **Section Purpose**: This section provides detailed information about all database objects that the stored procedure interacts with. It includes tables, views, and system objects with their usage patterns and key columns. Use this section to understand data dependencies, plan for schema changes, and assess the impact of modifications.

### Core Table Dependencies ([X] Tables)

| Table Name       | Usage Pattern                                   | Key Columns                           | Operations             |
| ---------------- | ----------------------------------------------- | ------------------------------------- | ---------------------- |
| **Table1** | [Primary data source/Target table/Lookup table] | `Column1`, `Column2`, `Column3` | SELECT, INSERT, UPDATE |
| **Table2** | [Description of usage]                          | `Column1`, `Column2`              | SELECT                 |
| **Table3** | [Description of usage]                          | `Column1`, `Column2`              | INSERT, UPDATE         |

### View Dependencies ([X] Views)

| View Name              | Purpose                       | Base Tables            | Usage            |
| ---------------------- | ----------------------------- | ---------------------- | ---------------- |
| **vw_ViewName1** | [Description of view purpose] | `Table1`, `Table2` | Data aggregation |
| **vw_ViewName2** | [Description of view purpose] | `Table3`             | Business logic   |

### System Object Dependencies

- **sys.indexes**: [Description of usage - e.g., Index existence validation]
- **sys.objects**: [Description of usage - e.g., Table existence validation]
- **OBJECT_ID()**: [Description of usage - e.g., Dynamic object resolution]

---

## Business Logic Configuration

> **Section Purpose**: This section documents the core business rules, algorithms, and configuration logic implemented within the stored procedure. It explains how business requirements are translated into SQL logic and highlights key decision points. Use this section to understand the business rationale behind the technical implementation.

### 1. [Primary Logic Category]

[Description of the main business logic implemented]

```sql
-- Example key logic snippet
[SQL CODE EXAMPLE]
```

### 2. [Secondary Logic Category]

[Description of additional business rules]

### 3. [Configuration Management]

**Configuration Tables:**
- **[Config Table 1]**: [Description and usage]
- **[Config Table 2]**: [Description and usage]

**Business Rules:**
- **[Rule 1]**: [Description]
- **[Rule 2]**: [Description]

---

## Technical Implementation Details

> **Section Purpose**: This section provides detailed technical information about the stored procedure's implementation, including performance optimizations, error handling strategies, and scalability considerations. Use this section to understand the technical architecture and identify potential areas for improvement.

### Performance Optimization Features

- **[Optimization 1]**: [Description]
- **[Optimization 2]**: [Description]
- **[Optimization 3]**: [Description]
- **[Optimization 4]**: [Description]

### Error Handling & Logging

- **[Error Handling Method]**: [Description]
- **[Logging Method]**: [Description]
- **[Audit Trail]**: [Description]
- **[Transaction Management]**: [Description]

### Scalability Considerations

- **[Scalability Feature 1]**: [Description]
- **[Scalability Feature 2]**: [Description]

---

## Appendix A: Table Schemas

> **Section Purpose**: This appendix provides complete table definitions including all columns, data types, constraints, and indexes for ALL tables that are dependencies of the stored procedure, including input tables (data sources), output tables (data targets), and intermediate tables. Use this section to understand the complete data structure landscape and plan for schema modifications or performance tuning.

**Instructions**: Document EVERY table that the stored procedure reads from, writes to, or references in any way. This includes:
- Input tables (SELECT operations)
- Output tables (INSERT/UPDATE/DELETE operations)
- Lookup tables (JOIN operations)
- Configuration tables (parameter/rule sources)
- Temporary tables (if created by the procedure)

### A.1 - [TableName1]

```sql
-- Table structure for [TableName1]
-- [Brief description of table purpose and role in procedure]

CREATE TABLE [dbo].[TableName1] (
    [Column1] [DataType] [NULL/NOT NULL],
    [Column2] [DataType] [NULL/NOT NULL],
    [Column3] [DataType] [NULL/NOT NULL],
    -- Add all columns with their data types

    CONSTRAINT [PK_TableName1] PRIMARY KEY ([Column1])
    -- Add other constraints
);

-- Indexes
CREATE NONCLUSTERED INDEX [IX_TableName1_Column2] ON [dbo].[TableName1] ([Column2]);
-- Add other indexes
```

**Usage in Procedure**: [Describe exactly how this table is used - input/output/lookup, which operations, frequency]
**Data Flow Role**: [Input/Output/Intermediate - describe role in overall data flow]

### A.2 - [TableName2]

```sql
-- Table structure for [TableName2]
-- [Brief description of table purpose and role in procedure]

CREATE TABLE [dbo].[TableName2] (
    [Column1] [DataType] [NULL/NOT NULL],
    [Column2] [DataType] [NULL/NOT NULL],
    -- Add all columns

    CONSTRAINT [PK_TableName2] PRIMARY KEY ([Column1])
);
```

**Usage in Procedure**: [Description of how this table is used]
**Data Flow Role**: [Input/Output/Intermediate - describe role in overall data flow]

**Continue this pattern for ALL dependent tables...**

---

## Appendix B: View Definitions

> **Section Purpose**: This appendix contains the complete source code for ALL views that are dependencies of the stored procedure. This includes views used for data input, data processing, and any views referenced directly or indirectly. Understanding view definitions is crucial for troubleshooting data issues and optimizing query performance.

**Instructions**: Document EVERY view that the stored procedure references, including:
- Views used in SELECT statements (data sources)
- Views used in JOIN operations (data relationships)
- Views referenced by called stored procedures (indirect dependencies)
- System views used for metadata operations

### B.1 - [ViewName1]

**Purpose**: [Description of what this view provides and its role in the procedure]
**Dependency Type**: [Direct/Indirect - explain how the procedure uses this view]

```sql
CREATE VIEW [dbo].[ViewName1]
AS
-- Complete view definition extracted from database
SELECT
    [Column1],
    [Column2],
    [Column3]
FROM [Table1] t1
INNER JOIN [Table2] t2 ON t1.[Column1] = t2.[Column1]
WHERE [Conditions]
```

**Base Tables**: [List all tables this view depends on]
**Usage in Procedure**: [Describe exactly how and where this view is used]

### B.2 - [ViewName2]

**Purpose**: [Description of what this view provides and its role in the procedure]
**Dependency Type**: [Direct/Indirect - explain how the procedure uses this view]

```sql
CREATE VIEW [dbo].[ViewName2]
AS
-- Complete view definition extracted from database
SELECT
    [Column1],
    [Column2]
FROM [Table3]
WHERE [Conditions]
```

**Base Tables**: [List all tables this view depends on]
**Usage in Procedure**: [Describe exactly how and where this view is used]

**Continue this pattern for ALL dependent views...**

**If No Views**: If the stored procedure has no view dependencies, state this clearly and explain that all data access is through direct table references.

---

## Appendix C: Related Functions and Stored Procedures

> **Section Purpose**: This appendix contains the complete source code for ALL functions and stored procedures that are dependencies of the main stored procedure. This includes procedures called directly, functions used in calculations, and any procedures/functions referenced indirectly. Understanding these implementations is essential for system maintenance and impact analysis.

**Instructions**: Document EVERY function and stored procedure dependency, including:
- Stored procedures called via EXEC statements (direct calls)
- Functions used in SELECT, WHERE, or calculation contexts
- Stored procedures called by other dependent procedures (indirect dependencies)
- System stored procedures if they perform business logic

### C.1 - [StoredProcedureName1]

**Purpose**: [Description of what this procedure does and its role in the workflow]
**Call Type**: [Direct/Indirect - explain how this procedure is invoked]
**Execution Order**: [Step number in the workflow, if applicable]

```sql
CREATE PROCEDURE [dbo].[StoredProcedureName1]
    @Parameter1 [DataType],
    @Parameter2 [DataType] = [DefaultValue]
AS
BEGIN
    -- Complete procedure source code extracted from database
    SET NOCOUNT ON;

    -- Variable declarations
    DECLARE @Variable1 [DataType]

    -- Main logic
    [Complete procedure implementation]

END
```

**Parameters**: [List and describe all input/output parameters]
**Dependencies**: [List tables, views, and other objects this procedure depends on]
**Usage in Main Procedure**: [Describe exactly when and how this is called]

### C.2 - [FunctionName1]

**Purpose**: [Description of what this function calculates/returns]
**Function Type**: [Scalar/Table-valued/Aggregate - specify function type]
**Usage Context**: [WHERE clause/SELECT list/JOIN condition - explain usage]

```sql
CREATE FUNCTION [dbo].[FunctionName1]
(
    @Parameter1 [DataType],
    @Parameter2 [DataType]
)
RETURNS [ReturnType]
AS
BEGIN
    -- Complete function source code extracted from database
    DECLARE @Result [ReturnType]

    -- Function logic
    [Complete function implementation]

    RETURN @Result
END
```

**Parameters**: [List and describe all input parameters]
**Return Value**: [Describe what the function returns]
**Usage in Main Procedure**: [Describe exactly where and how this function is used]

### C.3 - [StoredProcedureName2]

**Purpose**: [Description of what this procedure does]
**Call Type**: [Direct/Indirect - explain how this procedure is invoked]

```sql
CREATE PROCEDURE [dbo].[StoredProcedureName2]
    @Parameter1 [DataType]
AS
BEGIN
    -- Complete procedure source code
    [Complete procedure implementation]
END
```

**Continue this pattern for ALL dependent functions and stored procedures...**

**If No Dependencies**: If the stored procedure has no function or procedure dependencies, state this clearly and explain that all logic is self-contained.

---

## Appendix D: Target Stored Procedure Source Code

> **Section Purpose**: This appendix contains the complete source code of the stored procedure being analyzed. This is the definitive reference for understanding the exact implementation, including all parameters, variables, logic, and error handling.

### D.1 - Complete Source Code

```sql
CREATE PROCEDURE [dbo].[sp_ProcedureName]
    @Parameter1 [DataType],
    @Parameter2 [DataType] = [DefaultValue],
    @Parameter3 [DataType] OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variable declarations
    DECLARE @Variable1 [DataType]
    DECLARE @Variable2 [DataType]

    -- Main procedure logic
    BEGIN TRY
        -- Implementation here

    END TRY
    BEGIN CATCH
        -- Error handling

    END CATCH
END
```

**Key Features:**
- **Parameters**: [Description of parameters]
- **Return Values**: [Description of return values]
- **Error Handling**: [Description of error handling approach]
- **Transaction Management**: [Description if applicable]
- **Last Modified**: [Date if available]

---

## Analysis Methodology

> **Section Purpose**: This section documents the methodology, tools, and validation processes used to create this analysis report. It provides transparency about data collection methods and ensures the analysis can be reproduced or verified.

### Data Collection Process

1. **Real-time Database Connection**: Established live connection to `[Server].[Database]` using MCP tools
   - Connection established via: `mssql_connect`
   - Connection ID: `[Connection ID]`
   - Connection validated via: `mssql_get_connection_details`

2. **Source Code Extraction**: Retrieved complete procedure source using real-time MCP SQL queries
   - Query used: `SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('[ProcedureName]')`
   - Extraction timestamp: `[Timestamp]`

3. **Dependency Discovery**: Analyzed code dependencies using live database queries
   - Dependencies extracted via: `sys.sql_expression_dependencies` queries
   - Cross-referenced with: `sys.objects`, `sys.tables`, `sys.views`
   - All object names verified against current database state

4. **Schema Analysis**: Extracted complete schema definitions using real-time queries
   - Table schemas from: `information_schema.columns`
   - Index definitions from: `sys.indexes` and related system views
   - Constraint information from: `information_schema.table_constraints`

5. **Business Logic Analysis**: Reverse-engineered business requirements from live source code
   - Parameter definitions from: `sys.parameters`
   - Execution statistics from: `sys.dm_exec_procedure_stats` (if available)
   - Configuration data extracted via custom queries based on procedure logic

**Critical Data Freshness Note**: All data in this report reflects the exact state of the database at the time of analysis. No cached or historical data was used.

### Tools Used

- **MCP SQL Server**: Real-time database connectivity and query execution
- **Mermaid Diagrams**: Visual representation of dependencies and data flow
- **VS Code**: Documentation editing and formatting

### Validation

- **Syntax Verification**: All SQL code validated for syntax correctness
- **Dependency Verification**: Cross-referenced all object dependencies
- **Schema Accuracy**: Verified schema definitions against live database
- **Logic Review**: Validated business logic interpretation against code behavior

---

## Template Usage Instructions

**IMPORTANT**: Do NOT use emojis anywhere in the generated report.

### Step 1: Initial Setup

1. **Replace Placeholders**: Search for all `[Placeholder]` values and replace with actual data:
   - `[Date]` → Current date (e.g., "August 8, 2025")
   - `[Time]` → Current time (e.g., "14:30:00")
   - `[Server Name]` → Actual SQL Server name
   - `[Database Name]` → Target database name
   - `[Schema Name]` → Schema containing the procedure
   - `[Stored Procedure Name]` → Full procedure name (e.g., "sp_ProcessCustomerOrders")
   - `[Number]` → Actual count values

2. **Update File Name**: Rename template file to match procedure name
3. **Set Generation Context**: Add analyst name and analysis purpose

### Step 2: Business Requirements Reverse-Engineering

1. **Code Analysis Process**:
   - Connect to database using MCP SQL tools
   - Extract complete stored procedure source code
   - Identify business logic patterns (validation rules, calculations, workflows)
   - Look for configuration tables and parameters
   - Document error handling and audit mechanisms

2. **Business Requirements Mapping**:
   - Use BR-001 through BR-007 format for requirements
   - Each BR section should have: Requirement description, Key parameters, Business justification
   - Remove unused BR-00X sections if not applicable
   - Focus on what the code actually does, not what it should do

3. **Data Sources to Examine**:
   - Parameter validation logic
   - Configuration table queries
   - Business rule calculations
   - Audit and compliance features
   - Performance optimization patterns

### Step 3: Dependency Analysis

1. **Database Connection**:
   - Use `mssql_list_servers` to identify available servers
   - Use `mssql_connect` with server name from Step 1
   - Verify connection to correct database using `mssql_list_databases`
   - Document connection ID for reproducibility

2. **Source Code Extraction**:
   - Use `mssql_run_query` to get procedure definition:
     ```sql
     SELECT definition
     FROM sys.sql_modules
     WHERE object_id = OBJECT_ID('[Schema].[ProcedureName]');
     ```
   - Parse code for all object references
   - Identify direct and indirect dependencies

3. **Real-time Dependency Discovery**:
   - **Tables**: Use MCP query to get actual table dependencies:
     ```sql
     SELECT DISTINCT
         OBJECT_SCHEMA_NAME(referenced_id) as SchemaName,
         OBJECT_NAME(referenced_id) as TableName,
         referenced_column_name as ColumnName
     FROM sys.sql_expression_dependencies
     WHERE referencing_id = OBJECT_ID('[Schema].[ProcedureName]')
       AND referenced_id IS NOT NULL
       AND OBJECT_NAME(referenced_id) IS NOT NULL;
     ```

   - **Views**: Query for view dependencies:
     ```sql
     SELECT DISTINCT
         OBJECT_SCHEMA_NAME(referenced_id) as SchemaName,
         OBJECT_NAME(referenced_id) as ViewName
     FROM sys.sql_expression_dependencies
     WHERE referencing_id = OBJECT_ID('[Schema].[ProcedureName]')
       AND referenced_id IN (SELECT object_id FROM sys.views);
     ```

4. **Diagram Updates**:
   - Replace placeholder objects in Mermaid diagram with actual names from MCP queries
   - Add actual table/view/procedure names
   - Verify relationship arrows match dependency query results

### Step 4: Data Flow Documentation

1. **Execution Flow Analysis**:
   - Break procedure into logical steps
   - Document decision points and branching logic
   - Identify data transformation points
   - Map error handling paths

2. **Flow Documentation**:
   - Use numbered steps with descriptive names
   - Include conditional logic and loops
   - Document data validation checkpoints
   - Add performance-critical operations

### Step 5: Schema Documentation

1. **Table Schema Extraction**:
   - Use `mssql_run_query` with real-time schema queries for each referenced table:
     ```sql
     -- Get complete table schema
     SELECT
         c.column_name,
         c.data_type,
         c.character_maximum_length,
         c.is_nullable,
         c.column_default,
         CASE WHEN pk.column_name IS NOT NULL THEN 'YES' ELSE 'NO' END as is_primary_key
     FROM information_schema.columns c
     LEFT JOIN (
         SELECT ku.table_name, ku.column_name
         FROM information_schema.table_constraints tc
         JOIN information_schema.key_column_usage ku ON tc.constraint_name = ku.constraint_name
         WHERE tc.constraint_type = 'PRIMARY KEY'
     ) pk ON c.table_name = pk.table_name AND c.column_name = pk.column_name
     WHERE c.table_name = '[TableName]'
     ORDER BY c.ordinal_position;

     -- Get indexes for each table
     SELECT
         i.name as index_name,
         i.type_desc,
         i.is_unique,
         STRING_AGG(c.name, ', ') as columns
     FROM sys.indexes i
     JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
     JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
     WHERE i.object_id = OBJECT_ID('[Schema].[TableName]')
     GROUP BY i.name, i.type_desc, i.is_unique;
     ```

2. **View Documentation**:
   - Extract complete view definitions using MCP:
     ```sql
     SELECT definition
     FROM sys.sql_modules
     WHERE object_id = OBJECT_ID('[Schema].[ViewName]');
     ```
   - Document business purpose for each view based on actual definition
   - Include base table dependencies from real-time analysis

3. **Related Procedures**:
   - Query for procedures called by main procedure:
     ```sql
     SELECT DISTINCT
         OBJECT_SCHEMA_NAME(referenced_id) as SchemaName,
         OBJECT_NAME(referenced_id) as ProcedureName
     FROM sys.sql_expression_dependencies
     WHERE referencing_id = OBJECT_ID('[Schema].[ProcedureName]')
       AND referenced_id IN (SELECT object_id FROM sys.procedures);
     ```
   - Get parameter definitions for related procedures using MCP
   - Include brief purpose and parameter descriptions from actual source

### Step 6: Review and Validation

1. **Technical Validation**:
   - Test all SQL code snippets for syntax errors
   - Verify object names match database exactly
   - Confirm dependency relationships are accurate
   - Validate Mermaid diagram syntax

2. **Content Review**:
   - Ensure all placeholders are replaced
   - Verify business requirements reflect actual code behavior
   - Check that technical details match implementation
   - Confirm documentation is complete and coherent

3. **Final Checks**:
   - Remove any unused template sections
   - Verify no emojis are present in the document
   - Ensure formatting is consistent throughout
   - Add final generation timestamp

### Completion Checklist

**Pre-Analysis Setup**:
- [ ] Database connection established using `mssql_connect` and tested
- [ ] Connection validated using `mssql_get_connection_details`
- [ ] Target database confirmed using `mssql_list_databases`
- [ ] Stored procedure existence verified using `mssql_run_query`
- [ ] Template file renamed to match procedure
- [ ] All header placeholders replaced with actual values from MCP queries

**Real-time Data Collection**:
- [ ] Procedure source code extracted using `SELECT definition FROM sys.sql_modules`
- [ ] Dependencies identified using `sys.sql_expression_dependencies` queries
- [ ] Table schemas retrieved using `information_schema.columns` queries
- [ ] Index definitions extracted using `sys.indexes` queries
- [ ] View definitions retrieved using `sys.sql_modules` for view objects
- [ ] Parameter definitions extracted using `sys.parameters` queries
- [ ] Execution statistics gathered using `sys.dm_exec_procedure_stats` (if available)

**Content Development**:
- [ ] Executive summary completed with actual metrics from MCP queries
- [ ] All business requirements (BR-001 through BR-007) based on real code analysis
- [ ] Dependency diagram updated with actual object names from database
- [ ] Data flow analysis matches actual procedure logic from source code
- [ ] All referenced tables documented with live schema data
- [ ] All referenced views documented with current source code
- [ ] Related procedures documented with actual definitions
- [ ] Target procedure source code included from live extraction

**Quality Assurance**:
- [ ] No placeholder text ([brackets]) remains in document
- [ ] All SQL code syntax validated
- [ ] Mermaid diagram renders correctly
- [ ] No emojis present anywhere in document
- [ ] Business requirements reflect actual code behavior, not assumptions
- [ ] Technical details match database implementation
- [ ] Document formatting is consistent throughout

**Final Validation**:
- [ ] Report reviewed by another team member (if applicable)
- [ ] All dependencies cross-referenced and verified
- [ ] Analysis methodology documented for reproducibility
- [ ] Report ready for stakeholder review

---

## Troubleshooting Common Template Issues

### Issue 1: Mermaid Diagram Not Rendering
**Symptoms**: Diagram shows as code block instead of visual diagram
**Solutions**:
- Verify Mermaid syntax is correct (no extra spaces, proper arrows)
- Check that VS Code has Mermaid preview extension installed
- Ensure diagram code is within proper code fence with `mermaid` language identifier

### Issue 2: Database Connection Problems
**Symptoms**: Cannot extract schema or procedure definitions
**Solutions**:
- Use `mssql_list_servers` to verify available servers
- Confirm database name with `mssql_list_databases`
- Test connection with `mssql_get_connection_details`
- Check connection permissions for schema access
- Verify procedure exists with: `SELECT name FROM sys.procedures WHERE name = '[ProcedureName]'`

### Issue 3: Incomplete Business Requirements
**Symptoms**: BR sections are generic or don't reflect actual code behavior
**Solutions**:
- Focus on what the code actually does using real source from `sys.sql_modules`
- Use MCP queries to extract configuration tables and parameter validation patterns
- Query `sys.parameters` for actual parameter definitions and defaults
- Extract actual values from configuration tables using targeted MCP queries

### Issue 4: Missing Dependencies
**Symptoms**: Dependency analysis seems incomplete
**Solutions**:
- Use comprehensive dependency query: `sys.sql_expression_dependencies`
- Search procedure code for dynamic SQL that might reference objects
- Query for linked server references: check for openquery, openrowset patterns
- Look for system stored procedure calls and validate with `sys.procedures`

### Issue 5: Stale or Inaccurate Data
**Symptoms**: Report contains outdated information or assumptions
**Solutions**:
- Verify all data is from real-time MCP queries, not documentation
- Re-run all extraction queries to ensure current state
- Cross-reference multiple system views for data validation
- Include query timestamps to prove data freshness

---

*This template provides a comprehensive framework for creating detailed stored procedure dependency analysis reports with reverse-engineered business requirements. Follow the step-by-step instructions to ensure complete and accurate documentation.*
