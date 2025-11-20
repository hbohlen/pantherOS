# System Packages Specification

## ADDED Requirements

### Essential System Utilities

**Requirement**: Install core system utilities required for administration and system management.

**Configuration**:
```nix
environment.systemPackages = with pkgs; [
  vim
  git
  tmux
  htop
  ncdu
];
```

**Rationale**: These tools are fundamental for system administration, development workflows, and monitoring.

#### Scenario: Text Editing
**Given**: vim installed and configured  
**When**: Administrator needs to edit configuration files  
**Then**:
- vim available for file editing
- System configuration modifications possible
- Minimal dependencies required
- Consistent editing environment

#### Scenario: Version Control
**Given**: git installed  
**When**: Code or configuration updates needed  
**Then**:
- git available for version control
- Repository operations functional
- Configuration management possible
- Development workflows supported

#### Scenario: Terminal Management
**Given**: tmux installed  
**When**: Multiple terminal sessions needed  
**Then**:
- tmux creates persistent terminal sessions
- Multiple tasks can be managed simultaneously
- Remote session resilience improved
- System administration workflow enhanced

#### Scenario: Process Monitoring
**Given**: htop installed  
**When**: System performance analysis needed  
**Then**:
- htop provides real-time process monitoring
- CPU, memory, and process information visible
- System performance issues diagnosable
- Resource usage analysis possible

#### Scenario: Disk Usage Analysis
**Given**: ncdu installed  
**When**: Storage usage investigation needed  
**Then**:
- ncdu analyzes disk usage by directory
- Storage consumption patterns identified
- Space-saving opportunities discovered
- Filesystem optimization possible

### Filesystem Management Tools

**Requirement**: Install Btrfs-specific utilities for filesystem management and optimization.

**Configuration**:
```nix
environment.systemPackages = with pkgs; [
  btrfs-progs
  compsize
];
```

**Rationale**: Future disk layout will use Btrfs filesystem, requiring management tools for operations and monitoring.

#### Scenario: Btrfs Operations
**Given**: btrfs-progs installed  
**When**: Btrfs filesystem management needed  
**Then**:
- Btrfs filesystem operations available
- Subvolume management functional
- Snapshot operations supported
- Filesystem maintenance possible

#### Scenario: Compression Analysis
**Given**: compsize installed  
**When**: Btrfs compression effectiveness needs evaluation  
**Then**:
- compsize analyzes compression ratios
- Storage efficiency metrics available
- Compression optimization possible
- SSD longevity benefits calculated

### Package Selection Rationale

#### Minimal Toolset Principle
**Decision**: Install only essential tools to minimize attack surface and resource usage.

**Considerations**:
- **Security**: Fewer packages reduce vulnerability surface
- **Performance**: Minimal resource consumption
- **Maintenance**: Reduced update complexity
- **Functionality**: Essential tools for administration

#### Development Readiness
**Decision**: Include tools necessary for development and configuration management.

**Included Tools**:
- `vim`: Universal text editor
- `git`: Version control essential for NixOS
- `tmux`: Terminal multiplexing for remote work

#### System Monitoring
**Decision**: Include basic monitoring and analysis tools.

**Included Tools**:
- `htop`: Process monitoring
- `ncdu`: Disk usage analysis

#### Filesystem Preparation
**Decision**: Install Btrfs tools in preparation for future disk layout.

**Included Tools**:
- `btrfs-progs`: Complete Btrfs toolkit
- `compsize`: Compression analysis tool

## Implementation Details

### Package Configuration
```nix
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Essential utilities
    vim              # Text editor
    git              # Version control
    tmux             # Terminal multiplexer
    htop             # Process monitor
    ncdu             # Disk usage analyzer
    
    # Filesystem tools
    btrfs-progs      # Btrfs filesystem utilities
    compsize         # Compression analysis
  ];

  # Ensure packages are from nixos-25.05 channel
  nixpkgs.config = {
    packageOverrides = pkgs: {
      # Custom package overrides if needed
    };
  };
}
```

### Package Sources
- **Channel**: nixos-25.05 (stable)
- **Version**: Current stable for NixOS 25.05
- **Security**: All packages from official NixOS repository
- **Dependencies**: Automatic dependency resolution

### Security Considerations

#### Minimal Attack Surface
- **Essential Only**: Install only necessary packages
- **No Development Tools**: Avoid compilers and development utilities
- **No Network Tools**: Avoid additional network utilities
- **No Services**: No background services from package installation

#### Dependency Security
- **Official Sources**: All packages from nixpkgs
- **Stable Channel**: Use proven, stable package versions
- **No Untrusted Sources**: Avoid third-party package sources
- **Dependency Scanning**: Automatic vulnerability scanning via nixpkgs

### Resource Optimization

#### Disk Space
- **Minimal Packages**: Essential tools only
- **Shared Dependencies**: NixOS optimizes shared library usage
- **No Duplicates**: Avoid installing overlapping functionality
- **Compression Ready**: Btrfs compression will reduce footprint

#### Memory Usage
- **Lightweight Tools**: All selected tools are resource-efficient
- **No Daemons**: No background services installed
- **Low Overhead**: Minimal runtime resource consumption
- **Efficient Operations**: Tools optimized for server environment

### Integration Points

#### System Administration
- **SSH Access**: Tools accessible via SSH session
- **Remote Management**: All tools work over Tailscale VPN
- **Serial Console**: Tools available via Hetzner web console
- **Recovery**: Tools available during system recovery

#### Configuration Management
- **Version Control**: git for configuration tracking
- **File Editing**: vim for configuration modifications
- **Service Management**: Tools for systemd unit editing
- **Log Analysis**: Tools for log file examination

#### Monitoring and Debugging
- **Performance**: htop for system performance analysis
- **Storage**: ncdu for disk usage investigation
- **Filesystem**: btrfs-progs for filesystem operations
- **Compression**: compsize for storage optimization

### Testing Requirements

#### Package Installation Test
**Scenario**: System packages configured  
**When**: NixOS configuration applied  
**Then**:
- All packages installed successfully
- No dependency conflicts
- Tools accessible in PATH
- Versions match nixos-25.05

#### Functionality Test
**Scenario**: Tools installed  
**When**: Each tool executed  
**Then**:
- vim opens and edits files
- git manages repositories
- tmux creates sessions
- htop displays processes
- ncdu analyzes directories
- btrfs commands function
- compsize analyzes compression

#### Integration Test
**Scenario**: System running  
**When**: Administrative tasks performed  
**Then**:
- All tools work together seamlessly
- No conflicts between tools
- Performance acceptable
- Security maintained

### Future Package Considerations

#### Potential Additions
- **Monitoring**: Additional monitoring tools if needed
- **Network**: Network diagnostic tools
- **Security**: Security scanning tools
- **Backup**: Backup and restore utilities

#### Package Removal Strategy
- **Unused Tools**: Remove tools no longer needed
- **Security Updates**: Update packages regularly
- **Resource Optimization**: Optimize package selection
- **Dependency Cleanup**: Remove unnecessary dependencies

### Validation Criteria
- [ ] All essential utilities installed and functional
- [ ] Btrfs tools available for filesystem operations
- [ ] No unnecessary packages installed
- [ ] Tools accessible via SSH and console
- [ ] Security maintained with minimal attack surface
- [ ] Resource usage acceptable
- [ ] Package versions from nixos-25.05
- [ ] No dependency conflicts
- [ ] Tools work together seamlessly
- [ ] Future filesystem requirements addressed

---

**Spec Version**: 1.0  
**Last Updated**: 2025-11-19  
**Capability**: system-packages  
**Change ID**: nixos-base-hetzner-vps