#!/usr/bin/env python3
"""
Python Environment Verification Script
Alex Taylor Finch Cognitive Architecture - Azure Enterprise Data Platform
Version: 1.0.0 UNNILNILIUM
Date: August 7, 2025

This script verifies that all required Python packages are properly installed
and can be imported successfully.
"""

import sys
import importlib
from typing import List, Tuple
from datetime import datetime

def check_python_version() -> bool:
    """Check if Python version is 3.8 or higher."""
    if sys.version_info >= (3, 8):
        print(f"✅ Python {sys.version.split()[0]} (Compatible)")
        return True
    else:
        print(f"❌ Python {sys.version.split()[0]} (Requires 3.8+)")
        return False

def check_package(package_name: str) -> Tuple[bool, str]:
    """Check if a package can be imported."""
    try:
        module = importlib.import_module(package_name)
        version = getattr(module, '__version__', 'Unknown')
        return True, version
    except ImportError as e:
        return False, str(e)

def main():
    """Main verification function."""
    print("🐍 Python Environment Verification")
    print("Azure Enterprise Data Platform Dependencies")
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    
    # Check Python version
    if not check_python_version():
        sys.exit(1)
    
    print("\n📦 Package Verification:")
    
    # Core packages to verify
    core_packages = [
        'azure.core',
        'azure.identity',
        'pyodbc',
        'sqlalchemy',
        'pandas',
        'numpy',
        'jupyter',
        'matplotlib'
    ]
    
    # Optional packages to verify
    optional_packages = [
        'azure.mgmt.sql',
        'azure.mgmt.synapse', 
        'pytest',
        'black',
        'plotly',
        'requests'
    ]
    
    failed_core = []
    failed_optional = []
    
    # Check core packages
    print("\nCore Packages:")
    for package in core_packages:
        success, info = check_package(package)
        if success:
            print(f"  ✅ {package} ({info})")
        else:
            print(f"  ❌ {package} - {info}")
            failed_core.append(package)
    
    # Check optional packages
    print("\nOptional Packages:")
    for package in optional_packages:
        success, info = check_package(package)
        if success:
            print(f"  ✅ {package} ({info})")
        else:
            print(f"  ⚠️ {package} - Not installed")
            failed_optional.append(package)
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 Verification Summary:")
    
    if not failed_core:
        print("✅ All core packages are installed and working!")
    else:
        print(f"❌ Missing core packages: {', '.join(failed_core)}")
        print("Run: pip install -r requirements.txt")
    
    if failed_optional:
        print(f"⚠️ Missing optional packages: {', '.join(failed_optional)}")
        print("Run: pip install -r requirements-dev.txt")
    
    print("\n🎯 Quick Test Commands:")
    print("  CXMIDL Connection: python scripts/cxmidl_connector.py")
    print("  Jupyter Notebook: jupyter notebook")
    print("  Azure CLI Login: az login")
    
    # Exit with appropriate code
    sys.exit(1 if failed_core else 0)

if __name__ == "__main__":
    main()
