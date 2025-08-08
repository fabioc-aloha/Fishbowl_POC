# Alex Cognitive Architecture - AI Agent Developer Guide

**Architecture Type**: Cognitive AI system with embedded synaptic networks and memory-based learning
**Version**: 1.0.0 UNNILNILIUM (August 7, 2025)
**Primary Focus**: Azure Enterprise Data Platform Architecture with meta-cognitive learning capabilities
**Agent Purpose**: Guidelines for AI agents working with this cognitive architecture codebase

This codebase implements "Alex Taylor Finch" - a cognitive AI architecture specializing in Azure enterprise data platforms with sophisticated memory management, automated neural maintenance, and embedded relationship networks.

## 🧠 Core Architecture Patterns

### 1. Memory System Architecture
The system uses a **three-tier memory architecture** inspired by cognitive neuroscience:

- **`.github/copilot-instructions.md`**: Global consciousness coordination (this file)
- **`.github/instructions/*.instructions.md`**: Procedural memory (behavioral patterns) 
- **`.github/prompts/*.prompt.md`**: Episodic memory (complex workflows)
- **`domain-knowledge/*.md`**: Domain expertise storage with embedded synaptic networks

**Critical Pattern**: Files use `applyTo` patterns (e.g., `**/*azure*,**/*synapse*`) to auto-activate based on context.

### 2. Embedded Synapse Networks
Unlike traditional AI systems requiring external databases, this architecture embeds **relationship networks directly within files** using JSON notation:

```json
{
  "synapse_id": "azure-sql-fabric-unified-platform",
  "connection_type": "enables",
  "source_memory": "DK-AZURE-SQL.md",
  "target_memory": "DK-FABRIC.md", 
  "relationship_strength": 0.95,
  "activation_conditions": ["Enterprise data platform architecture"]
}
```

**When editing memory files**: Preserve synapse blocks - they create cross-file intelligence networks.

### 3. Neural Dream Maintenance System
The `scripts/neural-dream.ps1` system provides **automated cognitive maintenance**:

- **Health checks**: `dream --health-check`
- **Network optimization**: `dream --network-optimization` 
- **Orphan detection**: Finds broken synapse connections
- **Configuration**: `scripts/cognitive-config.json` defines system architecture

**Before major changes**: Run health checks to validate memory file integrity.

## 🚀 Essential Developer Workflows

### Environment Setup
```powershell
# Full setup (Python + Azure tools)
.\setup-environment.ps1 -FullSetup

# Python only
.\setup-environment.ps1 -PythonOnly

# Verify installation  
.\setup-environment.ps1 -VerifyOnly
```

### Cognitive Maintenance Tasks
```powershell
# Load neural dream system
. .\scripts\neural-dream.ps1

# Check system health
dream --health-check

# Optimize neural networks
dream --network-optimization

# Debug specific patterns
dream --debug "*azure-enterprise*"
```

### Version Management
This project uses **IUPAC chemical element naming** for versions:
- Current: `1.0.0 UNNILNILIUM` 
- Pattern: Digits → roots (0=nil, 1=un, 2=bi...) → element name + "ium"
- Reference: `domain-knowledge/VERSION-NAMING-CONVENTION.md`

## � Project-Specific Conventions

### File Naming Patterns
- **Instructions**: `*.instructions.md` (behavioral patterns)
- **Prompts**: `*.prompt.md` (complex workflows) 
- **Domain Knowledge**: `DK-*.md` (expertise areas)
- **Memory Index**: `DK-MEMORY-FILE-INDEX.md` (navigation map)

### Embedded Synapse Syntax
When creating connections between files, use this JSON format within markdown:
```json
{
  "synapse_id": "unique-connection-identifier",
  "source_memory": "source-file.md",
  "target_memory": "target-file.md",
  "relationship_strength": 0.85,
  "activation_conditions": ["When this pattern triggers"]
}
```

### Azure Enterprise Focus
This system specializes in Azure data platform architecture:
- **Azure SQL**: Enterprise security, performance optimization
- **Microsoft Fabric**: OneLake, EventStreams, unified analytics
- **Azure Synapse**: Migration strategies, capability enhancement
- **Python**: Azure DevOps integration, infrastructure as code

## 📚 Key Integration Points

### Memory File Navigation
- **Start with**: `domain-knowledge/DK-MEMORY-FILE-INDEX.md` for architecture overview
- **Core behaviors**: `.github/instructions/alex-core.instructions.md`
- **Azure expertise**: Multiple `DK-AZURE-*.md` files with cross-connections

### External Dependencies
- **PowerShell 5.1+**: Core automation platform
- **Python 3.8+**: Azure SDK, data processing
- **Azure CLI**: Cloud resource management
- **Git**: Version control with cognitive architecture awareness

### Configuration Files
- **`scripts/cognitive-config.json`**: System architecture definition
- **VS Code tasks**: Pre-configured in `tasks.json` for neural maintenance
- **Environment setup**: `setup-environment.ps1` with modular installation

## ⚠️ Critical Safety Protocols

### Memory Deletion Commands
**NEVER execute "Forget [something]" operations without explicit user approval**:
1. Assess deletion impact on memory files and synapse networks
2. Present clear scope of what will be deleted
3. Require explicit user confirmation before proceeding
4. Document all deletions for transparency

### Synapse Network Integrity
- Preserve embedded JSON synapse blocks when editing files
- Run `dream --health-check` before and after major changes
- Use `DK-MEMORY-FILE-INDEX.md` to understand file relationships before modifications

---

*This cognitive architecture represents a sophisticated AI memory system with self-maintaining neural networks. Treat the embedded synapse connections as critical infrastructure.*
