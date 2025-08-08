#!/usr/bin/env python3
"""
Dependency Conflict Resolver
Identifies and helps resolve Python package conflicts
"""

import subprocess
import sys
import os
from pathlib import Path
import json
import re

def run_command(cmd, capture_output=True):
    """Run a command and return the result"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=capture_output, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)

def check_pip_check():
    """Run pip check to identify conflicts"""
    print("🔍 Running pip check for dependency conflicts...")
    success, stdout, stderr = run_command("pip check")
    
    if success and not stdout.strip():
        print("✅ No dependency conflicts found!")
        return True, []
    else:
        conflicts = []
        if stdout:
            conflicts.extend(stdout.strip().split('\n'))
        if stderr:
            conflicts.extend(stderr.strip().split('\n'))
        
        print("❌ Dependency conflicts found:")
        for conflict in conflicts:
            if conflict.strip():
                print(f"   - {conflict}")
        return False, conflicts

def analyze_requirements_files():
    """Analyze requirements files for potential conflicts"""
    print("\n📋 Analyzing requirements files...")
    
    base_file = Path("requirements.txt")
    dev_file = Path("requirements-dev.txt")
    
    if not base_file.exists():
        print("❌ requirements.txt not found")
        return
    
    if not dev_file.exists():
        print("❌ requirements-dev.txt not found")
        return
    
    # Parse base requirements
    base_deps = {}
    with open(base_file, 'r') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#') and not line.startswith('-'):
                if '>=' in line:
                    name, version = line.split('>=', 1)
                    base_deps[name.strip()] = version.strip()
                elif '==' in line:
                    name, version = line.split('==', 1)
                    base_deps[name.strip()] = version.strip()
                else:
                    base_deps[line.strip()] = "any"
    
    print(f"📦 Found {len(base_deps)} base dependencies")
    
    # Check for common conflict patterns
    conflict_patterns = {
        'azure-core': 'Azure SDK conflicts',
        'pyspark': 'Spark version conflicts',
        'pandas': 'Data processing conflicts',
        'numpy': 'Numerical library conflicts',
        'jupyter': 'Jupyter ecosystem conflicts'
    }
    
    for package, description in conflict_patterns.items():
        if package in base_deps:
            print(f"   ⚠️ Watch for {description} with {package}>={base_deps[package]}")

def suggest_fixes():
    """Suggest fixes for common dependency issues"""
    print("\n🔧 Suggested Fixes:")
    print("=" * 60)
    
    fixes = [
        {
            "issue": "Azure SDK conflicts",
            "fix": "Use compatible azure-* package versions",
            "command": "pip install --upgrade azure-core azure-identity azure-mgmt-core"
        },
        {
            "issue": "PySpark version conflicts", 
            "fix": "Ensure PySpark and py4j versions are compatible",
            "command": "pip install --upgrade pyspark py4j"
        },
        {
            "issue": "Jupyter conflicts",
            "fix": "Update entire Jupyter ecosystem together",
            "command": "pip install --upgrade jupyter jupyterlab notebook ipykernel"
        },
        {
            "issue": "Data science stack conflicts",
            "fix": "Update core data science packages together",
            "command": "pip install --upgrade pandas numpy scipy scikit-learn"
        },
        {
            "issue": "Type checking conflicts",
            "fix": "Remove conflicting type stubs",
            "command": "pip uninstall azure-core-stubs types-azure-core"
        }
    ]
    
    for fix in fixes:
        print(f"🔹 {fix['issue']}:")
        print(f"   Solution: {fix['fix']}")
        print(f"   Command: {fix['command']}")
        print()

def create_clean_environment():
    """Create a clean virtual environment"""
    print("🧹 Clean Environment Setup:")
    print("=" * 60)
    
    steps = [
        "1. Backup current environment:",
        "   pip freeze > backup-requirements.txt",
        "",
        "2. Create fresh virtual environment:",
        "   python -m venv .venv-clean",
        "   .venv-clean\\Scripts\\activate  # Windows",
        "   # source .venv-clean/bin/activate  # Linux/Mac",
        "",
        "3. Install base requirements first:",
        "   pip install --upgrade pip setuptools wheel",
        "   pip install -r requirements.txt",
        "",
        "4. Test base installation:",
        "   python scripts/validate-environment.py",
        "",
        "5. Install dev requirements if needed:",
        "   pip install -r requirements-dev.txt",
        "",
        "6. Verify final installation:",
        "   pip check"
    ]
    
    for step in steps:
        print(step)

def check_package_versions():
    """Check versions of key packages"""
    print("\n📦 Key Package Versions:")
    print("=" * 60)
    
    key_packages = [
        'azure-core', 'azure-identity', 'pandas', 'numpy', 
        'pyspark', 'jupyter', 'notebook', 'python-dotenv'
    ]
    
    for package in key_packages:
        success, stdout, stderr = run_command(f"pip show {package}")
        if success:
            lines = stdout.split('\n')
            version_line = [l for l in lines if l.startswith('Version:')]
            if version_line:
                version = version_line[0].split(':', 1)[1].strip()
                print(f"✅ {package}: {version}")
            else:
                print(f"⚠️ {package}: Version not found")
        else:
            print(f"❌ {package}: Not installed")

def main():
    """Main function"""
    print("🔧 Python Dependency Conflict Resolver")
    print("=" * 60)
    print("Fishbowl POC Environment Diagnostics")
    print()
    
    # Check current environment
    if not os.path.exists('.venv'):
        print("⚠️ Virtual environment not found. Run setup-environment.ps1 first.")
        return
    
    print("🔍 Checking current environment...")
    
    # Check for conflicts
    has_conflicts, conflicts = check_pip_check()
    
    # Analyze requirements files
    analyze_requirements_files()
    
    # Show package versions
    check_package_versions()
    
    # Provide suggestions
    if has_conflicts:
        suggest_fixes()
        print("\n" + "="*60)
        create_clean_environment()
    else:
        print("\n✅ Environment appears to be healthy!")
        print("💡 If you're still experiencing issues:")
        print("   1. Try restarting your development environment")
        print("   2. Clear pip cache: pip cache purge") 
        print("   3. Reinstall specific problematic packages")
    
    print(f"\n📋 Summary:")
    print(f"   Conflicts detected: {'Yes' if has_conflicts else 'No'}")
    print(f"   Environment: {'Needs attention' if has_conflicts else 'Healthy'}")

if __name__ == "__main__":
    main()
