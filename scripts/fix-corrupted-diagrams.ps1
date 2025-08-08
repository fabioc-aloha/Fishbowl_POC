# Fix Corrupted Diagrams Script
# Repairs corrupted Unicode characters in documentation files
# Author: Alex Cognitive Architecture
# Date: August 7, 2025

Write-Host "🔧 Fixing corrupted diagrams and characters..." -ForegroundColor Cyan

$files = @(
    "README.md",
    "ARCHITECTURE.md", 
    "PROJECT-SUMMARY.md",
    "SYNAPSE-ONELAKE-INTEGRATION.md",
    "SETUP-COMPLETE.md"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "📝 Checking $file..." -ForegroundColor Yellow
        
        # Read content and fix common corruptions
        $content = Get-Content $file -Raw -Encoding UTF8
        
        # Fix corrupted folder icons
        $content = $content -replace "📁 synapse", "📁 synapse"
        $content = $content -replace "📁 machinelearning", "📁 machinelearning" 
        $content = $content -replace "📁 aas-container", "📁 aas-container"
        $content = $content -replace "📁 test", "📁 test"
        
        # Fix corrupted Unicode characters
        $content = $content -replace "�", "📁"
        $content = $content -replace "\uFFFD", "📁"
        
        # Fix incomplete mermaid diagrams
        if ($content -like "*```mermaid*" -and $content -notlike "*```*```*") {
            Write-Host "⚠️ Found incomplete mermaid diagram in $file" -ForegroundColor Yellow
        }
        
        # Write back with proper encoding
        $content | Out-File $file -Encoding UTF8 -NoNewline
        
        Write-Host "✅ Fixed $file" -ForegroundColor Green
    }
}

Write-Host "🎯 Diagram corruption repair complete!" -ForegroundColor Green
