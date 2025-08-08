"""
CXMIDL Azure SQL Server Integration Module - Orchestration Database Focus
Alex Taylor Finch Cognitive Architecture - Enterprise Data Platform
Version: 1.0.0 UNNILNILIUM

This module provides enterprise-grade connectivity to the CXMIDL Azure SQL Server
Orchestration database with MFA support, advanced security, monitoring, and 
integration capabilities.
"""

import pyodbc
import sqlalchemy as sa
from sqlalchemy import create_engine, text
from azure.identity import DefaultAzureCredential, ChainedTokenCredential, ManagedIdentityCredential, InteractiveBrowserCredential
import pandas as pd
import logging
from typing import Optional, Dict, Any, List, Union
from datetime import datetime
import json
from pathlib import Path

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class CXMIDLOrchestrationConnector:
    """Enterprise Azure SQL Server connector for CXMIDL Orchestration database."""
    
    def __init__(self, 
                 database: str = "Orchestration",
                 use_mfa: bool = True,
                 connection_timeout: int = 30,
                 command_timeout: int = 600):
        """
        Initialize CXMIDL Orchestration connector with enterprise security settings.
        
        Args:
            database: Target database name (default: Orchestration)
            use_mfa: Use Multi-Factor Authentication (Interactive Browser)
            connection_timeout: Connection timeout in seconds
            command_timeout: Command execution timeout in seconds
        """
        self.server = "cxmidl.database.windows.net"
        self.database = database
        self.use_mfa = use_mfa
        self.connection_timeout = connection_timeout
        self.command_timeout = command_timeout
        
        # Enterprise integration metadata
        self.integration_id = "cxmidl-orchestration-enterprise"
        self.version = "1.0.0_UNNILNILIUM"
        
        # Connection objects
        self._pyodbc_connection = None
        self._sqlalchemy_engine = None
        self._credential = None
        
        # Initialize Azure credential
        self._setup_credentials()
        
    def _setup_credentials(self):
        """Setup Azure authentication credentials with MFA support."""
        try:
            if self.use_mfa:
                # Use Interactive Browser as primary for MFA
                self._credential = ChainedTokenCredential(
                    InteractiveBrowserCredential(
                        tenant_id=None,  # Auto-detect tenant
                        redirect_uri="http://localhost:8400"
                    ),
                    DefaultAzureCredential(exclude_managed_identity_credential=True)
                )
                logger.info("MFA-enabled Azure credentials initialized")
            else:
                # Use default credential chain
                self._credential = DefaultAzureCredential()
                logger.info("Standard Azure credentials initialized")
        except Exception as e:
            logger.error(f"Failed to initialize Azure credentials: {e}")
            raise
    
    @property
    def connection_string(self) -> str:
        """Generate enterprise connection string."""
        if self.use_mfa:
            auth_method = "ActiveDirectoryInteractive"
        else:
            auth_method = "ActiveDirectoryDefault"
            
        return (
            f"Driver={{ODBC Driver 18 for SQL Server}};"
            f"Server=tcp:{self.server},1433;"
            f"Database={self.database};"
            f"Authentication={auth_method};"
            f"Encrypt=yes;"
            f"TrustServerCertificate=no;"
            f"Connection Timeout={self.connection_timeout};"
            f"Command Timeout={self.command_timeout};"
        )
    
    @property
    def sqlalchemy_url(self) -> str:
        """Generate SQLAlchemy connection URL."""
        from urllib.parse import quote_plus
        connection_string_encoded = quote_plus(self.connection_string)
        return f"mssql+pyodbc:///?odbc_connect={connection_string_encoded}"
    
    def connect(self) -> bool:
        """
        Establish connection to CXMIDL server.
        
        Returns:
            bool: True if connection successful, False otherwise
        """
        try:
            # Test PyODBC connection
            self._pyodbc_connection = pyodbc.connect(
                self.connection_string,
                timeout=self.connection_timeout
            )
            
            # Create SQLAlchemy engine
            self._sqlalchemy_engine = create_engine(
                self.sqlalchemy_url,
                connect_args={
                    "timeout": self.connection_timeout,
                    "autocommit": False
                },
                echo=False
            )
            
            # Test the connection
            with self._sqlalchemy_engine.connect() as conn:
                result = conn.execute(text("SELECT GETDATE() as CurrentTime"))
                current_time = result.fetchone()[0]
                
            logger.info(f"Successfully connected to CXMIDL server at {current_time}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to connect to CXMIDL server: {e}")
            self._cleanup_connections()
            return False
    
    def execute_query(self, 
                     query: str, 
                     params: Optional[Dict[str, Any]] = None,
                     return_dataframe: bool = True) -> Union[pd.DataFrame, List[Dict]]:
        """
        Execute SQL query with enterprise security and monitoring.
        
        Args:
            query: SQL query to execute
            params: Query parameters (optional)
            return_dataframe: Return results as pandas DataFrame
            
        Returns:
            Query results as DataFrame or list of dictionaries
        """
        if not self._sqlalchemy_engine:
            if not self.connect():
                raise ConnectionError("Failed to establish connection to CXMIDL server")
        
        try:
            start_time = datetime.now()
            
            with self._sqlalchemy_engine.connect() as conn:
                if return_dataframe:
                    df = pd.read_sql_query(query, conn, params=params)
                    execution_time = (datetime.now() - start_time).total_seconds()
                    
                    logger.info(f"Query executed successfully in {execution_time:.2f}s, returned {len(df)} rows")
                    return df
                else:
                    result = conn.execute(text(query), params or {})
                    rows = [dict(row._mapping) for row in result]
                    execution_time = (datetime.now() - start_time).total_seconds()
                    
                    logger.info(f"Query executed successfully in {execution_time:.2f}s, returned {len(rows)} rows")
                    return rows
                    
        except Exception as e:
            logger.error(f"Query execution failed: {e}")
            raise
    
    def get_server_info(self) -> Dict[str, Any]:
        """Get comprehensive server information."""
        info_query = """
        SELECT 
            @@SERVERNAME as ServerName,
            @@VERSION as SqlVersion,
            DB_NAME() as CurrentDatabase,
            SYSTEM_USER as CurrentUser,
            GETDATE() as CurrentTime,
            @@LANGUAGE as LanguageSetting,
            'N/A' as TextSizeInfo,
            'N/A' as LockTimeoutInfo
        """
        
        result = self.execute_query(info_query, return_dataframe=False)
        return result[0] if result else {}
    
    def get_databases(self) -> pd.DataFrame:
        """Get list of available databases."""
        db_query = """
        SELECT 
            name as DatabaseName,
            database_id as DatabaseId,
            create_date as CreatedDate,
            collation_name as Collation,
            state_desc as State,
            compatibility_level as CompatibilityLevel
        FROM sys.databases 
        WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')
        ORDER BY name
        """
        
        return self.execute_query(db_query)
    
    def get_orchestration_analysis(self) -> Dict[str, Any]:
        """Get comprehensive Orchestration database analysis."""
        orchestration_query = """
        -- Orchestration Database Comprehensive Analysis
        SELECT 
            'Database_Metadata' as AnalysisType,
            DB_NAME() as DatabaseName,
            SYSTEM_USER as CurrentUser,
            @@SPID as SessionId,
            GETDATE() as AnalysisTime,
            @@VERSION as SqlVersion
            
        UNION ALL
        
        SELECT 
            'Schema_Count' as AnalysisType,
            CAST(COUNT(DISTINCT SCHEMA_NAME) as VARCHAR(50)) as Value,
            NULL, NULL, NULL, NULL
        FROM INFORMATION_SCHEMA.SCHEMATA
        WHERE SCHEMA_NAME NOT IN ('sys', 'INFORMATION_SCHEMA')
        
        UNION ALL
        
        SELECT 
            'Table_Count' as AnalysisType,
            CAST(COUNT(*) as VARCHAR(50)) as Value,
            NULL, NULL, NULL, NULL
        FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_TYPE = 'BASE TABLE'
        
        UNION ALL
        
        SELECT 
            'View_Count' as AnalysisType,
            CAST(COUNT(*) as VARCHAR(50)) as Value,
            NULL, NULL, NULL, NULL
        FROM INFORMATION_SCHEMA.VIEWS
        
        UNION ALL
        
        SELECT 
            'Stored_Procedure_Count' as AnalysisType,
            CAST(COUNT(*) as VARCHAR(50)) as Value,
            NULL, NULL, NULL, NULL
        FROM INFORMATION_SCHEMA.ROUTINES 
        WHERE ROUTINE_TYPE = 'PROCEDURE'
        
        UNION ALL
        
        SELECT 
            'Function_Count' as AnalysisType,
            CAST(COUNT(*) as VARCHAR(50)) as Value,
            NULL, NULL, NULL, NULL
        FROM INFORMATION_SCHEMA.ROUTINES 
        WHERE ROUTINE_TYPE = 'FUNCTION'
        
        ORDER BY AnalysisType
        """
        
        try:
            result = self.execute_query(orchestration_query, return_dataframe=False)
            
            # Structure the results
            analysis = {
                "timestamp": datetime.now().isoformat(),
                "database": self.database,
                "server": self.server,
                "integration_id": self.integration_id
            }
            
            for item in result:
                if item['AnalysisType'] == 'Database_Metadata':
                    analysis.update({
                        "database_name": item['DatabaseName'],
                        "current_user": item['CurrentUser'],
                        "session_id": item['SessionId'],
                        "analysis_time": item['AnalysisTime'].isoformat() if item['AnalysisTime'] else None,
                        "sql_version": item['SqlVersion']
                    })
                else:
                    analysis[item['AnalysisType'].lower()] = int(item['Value']) if item['Value'] else 0
            
            logger.info(f"Orchestration database analysis completed: {len(result)} metrics collected")
            return analysis
            
        except Exception as e:
            logger.error(f"Orchestration analysis failed: {e}")
            return {
                "timestamp": datetime.now().isoformat(),
                "database": self.database,
                "server": self.server,
                "error": str(e),
                "integration_id": self.integration_id
            }
    
    def get_orchestration_tables(self, schema: str = "dbo") -> pd.DataFrame:
        """Get detailed table information for Orchestration database."""
        tables_query = """
        SELECT 
            t.TABLE_SCHEMA as SchemaName,
            t.TABLE_NAME as TableName,
            t.TABLE_TYPE as TableType,
            c.COLUMN_COUNT as ColumnCount,
            CASE 
                WHEN t.TABLE_NAME LIKE '%orchestr%' OR t.TABLE_NAME LIKE '%workflow%' OR t.TABLE_NAME LIKE '%job%' OR t.TABLE_NAME LIKE '%task%' THEN 'Orchestration_Core'
                WHEN t.TABLE_NAME LIKE '%log%' OR t.TABLE_NAME LIKE '%audit%' OR t.TABLE_NAME LIKE '%history%' THEN 'Logging_Audit'
                WHEN t.TABLE_NAME LIKE '%config%' OR t.TABLE_NAME LIKE '%setting%' OR t.TABLE_NAME LIKE '%param%' THEN 'Configuration'
                ELSE 'General'
            END as TableCategory
        FROM INFORMATION_SCHEMA.TABLES t
        LEFT JOIN (
            SELECT 
                TABLE_SCHEMA,
                TABLE_NAME,
                COUNT(*) as COLUMN_COUNT
            FROM INFORMATION_SCHEMA.COLUMNS
            GROUP BY TABLE_SCHEMA, TABLE_NAME
        ) c ON t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
        WHERE t.TABLE_SCHEMA = ?
        ORDER BY TableCategory, t.TABLE_NAME
        """
        
        return self.execute_query(tables_query, params={"schema": schema})
        """Get table information for a specific schema."""
        table_query = """
        SELECT 
            t.TABLE_SCHEMA as SchemaName,
            t.TABLE_NAME as TableName,
            t.TABLE_TYPE as TableType,
            c.COLUMN_COUNT as ColumnCount
        FROM INFORMATION_SCHEMA.TABLES t
        LEFT JOIN (
            SELECT 
                TABLE_SCHEMA,
                TABLE_NAME,
                COUNT(*) as COLUMN_COUNT
            FROM INFORMATION_SCHEMA.COLUMNS
            GROUP BY TABLE_SCHEMA, TABLE_NAME
        ) c ON t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
        WHERE t.TABLE_SCHEMA = ?
        ORDER BY t.TABLE_NAME
        """
        
        return self.execute_query(table_query, params={"schema": schema})
    
    def health_check(self) -> Dict[str, Any]:
        """Perform comprehensive health check."""
        try:
            # Basic connectivity
            server_info = self.get_server_info()
            
            # Performance metrics
            perf_query = """
            SELECT 
                (SELECT COUNT(*) FROM sys.dm_exec_sessions WHERE is_user_process = 1) as ActiveSessions,
                (SELECT COUNT(*) FROM sys.dm_exec_requests) as ActiveRequests,
                (SELECT COUNT(*) FROM sys.databases WHERE state_desc = 'ONLINE') as OnlineDatabases
            """
            perf_result = self.execute_query(perf_query, return_dataframe=False)[0]
            
            health_status = {
                "timestamp": datetime.now().isoformat(),
                "server": self.server,
                "database": self.database,
                "connection_status": "healthy",
                "server_info": server_info,
                "performance_metrics": perf_result,
                "integration_id": self.integration_id,
                "version": self.version
            }
            
            logger.info("Health check completed successfully")
            return health_status
            
        except Exception as e:
            logger.error(f"Health check failed: {e}")
            return {
                "timestamp": datetime.now().isoformat(),
                "server": self.server,
                "connection_status": "unhealthy",
                "error": str(e),
                "integration_id": self.integration_id
            }
    
    def _cleanup_connections(self):
        """Clean up connection objects."""
        try:
            if self._pyodbc_connection:
                self._pyodbc_connection.close()
                self._pyodbc_connection = None
                
            if self._sqlalchemy_engine:
                self._sqlalchemy_engine.dispose()
                self._sqlalchemy_engine = None
                
        except Exception as e:
            logger.error(f"Error during connection cleanup: {e}")
    
    def close(self):
        """Close all connections and clean up resources."""
        self._cleanup_connections()
        logger.info("CXMIDL connector closed successfully")
    
    def __enter__(self):
        """Context manager entry."""
        self.connect()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self.close()


# Enterprise Integration Functions
def create_cxmidl_connector(database: str = "Orchestration") -> CXMIDLOrchestrationConnector:
    """
    Factory function to create CXMIDL connector with enterprise defaults.
    
    Args:
        database: Target database name
        
    Returns:
        CXMIDLOrchestrationConnector instance
    """
    return CXMIDLOrchestrationConnector(database=database)


def test_cxmidl_integration() -> Dict[str, Any]:
    """
    Test CXMIDL integration and return comprehensive status.
    
    Returns:
        Integration test results
    """
    try:
        with create_cxmidl_connector() as connector:
            return connector.health_check()
    except Exception as e:
        return {
            "timestamp": datetime.now().isoformat(),
            "server": "cxmidl.database.windows.net",
            "connection_status": "failed",
            "error": str(e),
            "integration_id": "cxmidl-azure-sql-enterprise"
        }


if __name__ == "__main__":
    # Example usage and testing
    print("🏢 CXMIDL Azure SQL Server Integration Test")
    print("=" * 50)
    
    # Test integration
    test_results = test_cxmidl_integration()
    print(json.dumps(test_results, indent=2, default=str))
    
    # Interactive example
    try:
        with create_cxmidl_connector() as connector:
            print("\n📊 Server Information:")
            server_info = connector.get_server_info()
            for key, value in server_info.items():
                print(f"  {key}: {value}")
            
            print("\n📚 Available Databases:")
            databases = connector.get_databases()
            print(databases.to_string(index=False))
            
    except Exception as e:
        print(f"❌ Integration test failed: {e}")
