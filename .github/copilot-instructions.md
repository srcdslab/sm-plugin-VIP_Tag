# Copilot Instructions for VIP_Tag Plugin

## Repository Overview

This repository contains a SourcePawn plugin for SourceMod that provides VIP tag functionality for Source engine game servers. The plugin integrates with the VIP_Core system to display customizable clan tags for VIP players in CS:GO and other Source games.

**Key Components:**
- Single plugin: `VIP_Tag.sp` - Manages VIP tag display and toggling
- Build system: SourceKnight (configured via `sourceknight.yaml`)
- CI/CD: GitHub Actions for automated building and releases
- Dependencies: SourceMod 1.11.0+ and VIP_Core plugin

## Technical Environment

### Language & Platform
- **Language**: SourcePawn (.sp files)
- **Platform**: SourceMod 1.11.0+ (Source engine scripting platform)
- **Compiler**: SourcePawn compiler (spcomp) via SourceKnight
- **Target Games**: CS:GO and other Source engine games

### Build System
This project uses **SourceKnight** for building and dependency management:
- Configuration: `sourceknight.yaml`
- Build command: `sourceknight build` (via GitHub Actions)
- Output directory: `/addons/sourcemod/plugins`
- Dependency management: Automatic download and setup of SourceMod and VIP_Core

### Dependencies
1. **SourceMod**: Version 1.11.0-git6917 (automatically downloaded)
2. **VIP_Core**: Latest from GitHub (srcdslab/sm-plugin-VIP-Core)

## Code Style & Standards

### SourcePawn Conventions
```sourcepawn
#pragma semicolon 1          // Always use semicolons
#pragma newdecls required    // Use new declaration syntax

// Variable naming
int g_GlobalVariable;        // Global variables: PascalCase with g_ prefix
int localVariable;           // Local variables: camelCase
char sStringVar[64];         // String variables: prefix with 's'

// Function naming
public void MyFunction()     // Public functions: PascalCase
void myPrivateFunction()     // Private functions: camelCase
```

### Best Practices
- **Indentation**: Use tabs (4 spaces equivalent)
- **No trailing spaces**
- **Descriptive naming**: Use clear, descriptive variable and function names
- **Memory management**: Use `delete` for cleanup (no null checks needed)
- **Error handling**: Implement proper error handling for all API calls
- **String operations**: Use StringMap/ArrayList instead of arrays where appropriate

### Plugin Structure
```sourcepawn
// Standard plugin structure:
public Plugin myinfo = { ... };    // Plugin metadata
public void OnPluginStart() { ... } // Initialization
public void OnPluginEnd() { ... }   // Cleanup (if needed)
// Event handlers and feature implementations
```

## Development Workflow

### Setting Up Development Environment
1. **Clone repository**: Repository contains all necessary configuration
2. **Dependencies**: Managed automatically by SourceKnight via `sourceknight.yaml`
3. **Build**: Use GitHub Actions or local SourceKnight installation

### Making Changes
1. **Edit plugin**: Modify `addons/sourcemod/scripting/VIP_Tag.sp`
2. **Test locally**: Use SourceKnight build or test server
3. **Commit changes**: Follow semantic commit messages
4. **CI/CD**: GitHub Actions automatically builds and tests

### File Structure
```
/addons/sourcemod/scripting/
├── VIP_Tag.sp                 # Main plugin file
└── include/                   # Dependencies (auto-managed)
    ├── sourcemod.inc
    ├── cstrike.inc
    └── vip_core.inc
```

## Build & Testing

### Local Development
```bash
# If using SourceKnight locally:
sourceknight build

# Output will be in:
.sourceknight/package/addons/sourcemod/plugins/VIP_Tag.smx
```

### CI/CD Pipeline
- **Trigger**: Push, PR, or manual dispatch
- **Build**: SourceKnight action builds plugin
- **Artifacts**: Compiled `.smx` files packaged for release
- **Releases**: Automatic releases for main branch and tags

### Testing Guidelines
- **Compile testing**: Ensure plugin compiles without errors/warnings
- **Server testing**: Test on development server with VIP_Core installed
- **Feature testing**: Verify tag toggling and display functionality
- **Compatibility**: Test with target SourceMod version (1.11.0+)

## Plugin-Specific Context

### VIP_Tag Functionality
This plugin provides:
- **VIP tag display**: Shows custom clan tags for VIP players
- **Toggle feature**: VIPs can enable/disable their tags
- **Integration**: Works with VIP_Core feature system
- **Game support**: Primarily CS:GO via clan tag system

### Key Functions
```sourcepawn
// VIP_Core integration callbacks
public void VIP_OnVIPLoaded()           // Register with VIP system
public void VIP_OnVIPClientLoaded()     // Handle VIP client connection
public Action OnToggleItem()            // Handle tag toggle

// Core functionality
public void SetVipTag(int client)       // Apply tag to client
```

### Configuration
- **No config files**: Plugin uses VIP_Core's configuration system
- **Feature name**: "Tag" (defined as VIP_TAG constant)
- **Feature type**: STRING with TOGGLABLE capability

## Common Tasks

### Adding New Features
1. **Extend VIP_Core integration**: Register additional features
2. **Follow existing patterns**: Use similar structure to tag system
3. **Test thoroughly**: Ensure compatibility with existing VIP system

### Debugging
- **SourceMod logs**: Check server console and log files
- **Error handling**: Use proper SourceMod error reporting
- **Client validation**: Always validate client indices and VIP status

### Version Management
- **Semantic versioning**: Update version in plugin info block
- **Git tags**: Use tags for releases (triggers automated builds)
- **Changelog**: Document changes in commit messages

## Performance Considerations

### Optimization Guidelines
- **Minimal operations**: Keep frequently called functions lightweight
- **Caching**: Cache expensive operations where possible
- **Event-driven**: Use SourceMod's event system efficiently
- **Memory**: Proper cleanup of handles and allocated memory

### CS:GO Specific
- **Clan tags**: CS_SetClientClanTag is game-specific
- **Client limits**: Consider server player limits
- **Update frequency**: Tag updates should be minimal and efficient

## Dependencies & Integration

### VIP_Core Integration
- **Required**: Plugin cannot function without VIP_Core
- **Feature registration**: Must register during VIP_OnVIPLoaded
- **Client handling**: Use VIP_Core's client management
- **String features**: Utilize VIP_Core's string feature system

### SourceMod API Usage
- **Client management**: Use SourceMod client functions
- **Game integration**: CS:GO-specific functions via cstrike include
- **Event handling**: Follow SourceMod event patterns

## Troubleshooting

### Common Issues
1. **VIP_Core not loaded**: Ensure VIP_Core is installed and loaded first
2. **Compilation errors**: Check SourceMod version compatibility
3. **Tag not displaying**: Verify CS:GO clan tag functionality
4. **Feature not registered**: Check VIP_OnVIPLoaded implementation

### Development Tips
- **Use SourceMod's built-in debugging**: Enable debug mode for detailed logs
- **Test incremental changes**: Small changes are easier to debug
- **Check game compatibility**: Some features may be game-specific
- **Follow SourceMod documentation**: Official docs are the authoritative source

## Resources

### Documentation
- [SourceMod Documentation](https://sm.alliedmods.net/new-api/)
- [SourcePawn Language Reference](https://wiki.alliedmods.net/SourcePawn)
- [VIP_Core Plugin](https://github.com/srcdslab/sm-plugin-VIP-Core)

### Tools
- [SourceKnight](https://github.com/maxime1907/sourceknight) - Build system
- [SM Dev Environment](https://sm.alliedmods.net/) - Official development tools

This plugin represents a simple but well-structured example of SourceMod plugin development with proper dependency management and CI/CD integration.