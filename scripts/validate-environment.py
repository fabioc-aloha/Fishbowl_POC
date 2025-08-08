#!/usr/bin/env python3
"""
Environment Configuration Validator
Validates that all required environment variables are properly set
"""

import os
import sys
from pathlib import Path

def load_env_file():
    """Load environment variables from .env file"""
    try:
        from dotenv import load_dotenv
        env_path = Path(__file__).parent / '.env'
        load_dotenv(env_path)
        return True, "✅ Environment file loaded successfully"
    except ImportError:
        return False, "❌ python-dotenv not installed. Run: pip install python-dotenv"
    except Exception as e:
        return False, f"❌ Error loading .env file: {str(e)}"

def validate_required_variables():
    """Validate that required environment variables are set"""
    required_vars = {
        'AZURE_SUBSCRIPTION_ID': 'Azure subscription ID',
        'FABRIC_WORKSPACE_ID': 'Microsoft Fabric workspace ID',
        'STORAGE_ACCOUNT_NAME': 'Azure storage account name',
        'DATA_FORMAT': 'Data format (e.g., PARQUET)',
        'TABLE_PREFIX': 'Table prefix for generated tables'
    }
    
    optional_vars = {
        'FABRIC_WORKSPACE_NAME': 'Fabric workspace name',
        'AZURE_RESOURCE_GROUP': 'Azure resource group',
        'SYNAPSE_WORKSPACE_NAME': 'Synapse workspace name',
        'FABRIC_ENVIRONMENT': 'Fabric environment'
    }
    
    print("🔍 Validating Required Environment Variables:")
    print("=" * 60)
    
    all_valid = True
    
    # Check required variables
    for var, description in required_vars.items():
        value = os.getenv(var)
        if value:
            # Mask sensitive values
            display_value = value if len(value) < 20 else f"{value[:8]}...{value[-4:]}"
            print(f"✅ {var}: {display_value}")
        else:
            print(f"❌ {var}: NOT SET ({description})")
            all_valid = False
    
    print("\n🔍 Optional Environment Variables:")
    print("=" * 60)
    
    # Check optional variables
    for var, description in optional_vars.items():
        value = os.getenv(var)
        if value:
            display_value = value if len(value) < 30 else f"{value[:15]}...{value[-8:]}"
            print(f"✅ {var}: {display_value}")
        else:
            print(f"⚠️ {var}: Not set ({description})")
    
    return all_valid

def validate_paths():
    """Validate that required paths exist"""
    print(f"\n🔍 Validating Project Paths:")
    print("=" * 60)
    
    required_paths = [
        'notebooks/',
        'scripts/',
        'domain-knowledge/',
        '.github/instructions/',
        'requirements.txt'
    ]
    
    all_paths_valid = True
    
    for path_str in required_paths:
        path = Path(path_str)
        if path.exists():
            path_type = "📁" if path.is_dir() else "📄"
            print(f"✅ {path_type} {path_str}: Found")
        else:
            print(f"❌ 📁 {path_str}: Missing")
            all_paths_valid = False
    
    return all_paths_valid

def show_configuration_summary():
    """Show a summary of the current configuration"""
    print(f"\n📋 Configuration Summary:")
    print("=" * 60)
    
    # Key configuration items
    config_items = [
        ('Project', os.getenv('PROJECT_NAME', 'Fishbowl_POC')),
        ('Storage Account', os.getenv('STORAGE_ACCOUNT_NAME', 'Not set')),
        ('Workspace', os.getenv('FABRIC_WORKSPACE_NAME', 'Not set')),
        ('Environment', os.getenv('FABRIC_ENVIRONMENT', 'Not set')),
        ('Data Format', os.getenv('DATA_FORMAT', 'Not set')),
        ('Table Prefix', os.getenv('TABLE_PREFIX', 'Not set')),
        ('Auth Compliance', os.getenv('USE_WORKSPACE_ID', 'Not set')),
    ]
    
    for label, value in config_items:
        print(f"  {label}: {value}")

def main():
    """Main validation function"""
    print("🚀 Fishbowl POC Environment Validation")
    print("=" * 60)
    
    # Load environment file
    env_loaded, env_message = load_env_file()
    print(env_message)
    
    if not env_loaded:
        print("\n💡 To fix:")
        print("  1. Install python-dotenv: pip install python-dotenv")
        print("  2. Create .env file from .env.template")
        print("  3. Fill in your specific values")
        return False
    
    # Validate variables
    vars_valid = validate_required_variables()
    
    # Validate paths
    paths_valid = validate_paths()
    
    # Show summary
    show_configuration_summary()
    
    # Final result
    print(f"\n🎯 Validation Result:")
    print("=" * 60)
    
    if vars_valid and paths_valid:
        print("✅ All validations passed! Environment is ready.")
        print("\n🚀 You can now run the discovery notebook:")
        print("  notebooks/cpestaginglake-discovery-mapping.ipynb")
        return True
    else:
        print("❌ Some validations failed. Please fix the issues above.")
        if not vars_valid:
            print("  - Update your .env file with required variables")
        if not paths_valid:
            print("  - Ensure all project directories exist")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
