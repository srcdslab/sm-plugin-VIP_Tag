# Copilot Instructions for VIP_Tag Plugin

## Repository Overview

This repository contains a SourcePawn plugin for SourceMod that provides VIP tag functionality for Source engine game servers. The plugin integrates with the VIP_Core system to display customizable clan tags for VIP players in CS:GO and other Source games.

**Key Components:**
- Single plugin: `VIP_Tag.sp` - Manages VIP tag display and toggling
- Build system: Native GitHub Actions (spcomp via `rumblefrog/setup-sp`, configured in `.github/workflows/ci.yml`)
- CI/CD: GitHub Actions for automated building and releases
- Dependencies: SourceMod 1.12.x and VIP_Core plugin

## Technical Environment

### Language & Platform
- **Language**: SourcePawn (.sp files)
- **Platform**: SourceMod 1.11.0+ (Source engine scripting platform)
- **Compiler**: SourcePawn compiler (spcomp) via GitHub Actions (`rumblefrog/setup-sp`)
- **Target Games**: CS:GO and other Source engine games

### Build System
This project uses **native GitHub Actions** for building and dependency management:
- Configuration: `.github/workflows/ci.yml`
- Build command: `spcomp` invoked directly (via `rumblefrog/setup-sp` action)
- Output directory: `addons/sourcemod/plugins`
- Dependency management: `git clone` of VIP_Core into `deps/`, includes copied into `addons/sourcemod/scripting/include`

### Dependencies
1. **SourceMod**: Version 1.12.x (installed via `rumblefrog/setup-sp` in CI)
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
2. **Dependencies**: Fetched by the CI workflow via `git clone` of VIP_Core
3. **Build**: Use GitHub Actions, or run `spcomp` locally with SourceMod 1.12.x and the VIP_Core includes

### Making Changes
1. **Edit plugin**: Modify `addons/sourcemod/scripting/VIP_Tag.sp`
2. **Test locally**: Use spcomp build or test server
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
# Compile with spcomp (SourceMod 1.12.x, VIP_Core includes on the include path):
spcomp -i include -o ../plugins/VIP_Tag.smx VIP_Tag.sp

# Output will be in:
addons/sourcemod/plugins/VIP_Tag.smx
```

### CI/CD Pipeline
- **Trigger**: Push, PR, or manual dispatch
- **Build**: GitHub Actions installs spcomp via `rumblefrog/setup-sp`, clones VIP_Core, and compiles the plugin
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
- [setup-sp](https://github.com/rumblefrog/setup-sp) - GitHub Action that installs the SourcePawn compiler
- [SM Dev Environment](https://sm.alliedmods.net/) - Official development tools

This plugin represents a simple but well-structured example of SourceMod plugin development with proper dependency management and CI/CD integration.