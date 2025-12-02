# Design: Refactor and Enhance Infrastructure

## Context

The pantherOS NixOS configuration has grown organically and accumulated technical debt in several areas:

1. **Module organization**: Large monolithic modules make navigation and maintenance difficult
2. **Hardware detection**: Rich facter.json data is available but underutilized
3. **Developer experience**: Missing essential tools for productive development
4. **Terminal workflow**: No terminal multiplexer configured, limiting multitasking

This change addresses all four areas systematically.

## Goals

1. **Improve maintainability** through better module organization
2. **Maximize hardware detection** by fully utilizing facter.json data
3. **Enhance developer productivity** with comprehensive tooling
4. **Enable efficient workflows** through terminal multiplexing

## Non-Goals

1. Changing functional behavior of existing configurations
2. Introducing breaking changes to host configurations
3. Replacing existing tools (e.g., not replacing fish shell or ghostty)
4. Adding runtime dependencies that increase closure size significantly

## Decisions

### Module Refactoring Strategy

**Decision**: Use directory-based decomposition with aggregator pattern

**Rationale**:
- Keeps related components together in subdirectories
- Main module file becomes simple aggregator (imports only)
- Maintains backward compatibility (existing imports work unchanged)
- Clear file organization makes navigation easier

**Example**:
```nix
# Before: modules/desktop-shells/dankmaterial/widgets.nix (407 lines)

# After:
# modules/desktop-shells/dankmaterial/widgets.nix (20 lines, imports only)
# modules/desktop-shells/dankmaterial/widgets/system-monitoring.nix
# modules/desktop-shells/dankmaterial/widgets/media-controls.nix
# modules/desktop-shells/dankmaterial/widgets/network-status.nix
# ... etc
```

**Alternatives considered**:
- **Flat structure with prefixes**: Rejected - harder to navigate, unclear groupings
- **Complete rewrite**: Rejected - high risk, unnecessary scope
- **Keep as-is**: Rejected - maintainability continues to degrade

### Hardware Detection Pattern

**Decision**: Create parsing utilities in lib/ that extract facter.json data into structured attributes

**Rationale**:
- Separates parsing logic from configuration
- Reusable across all hosts
- Type-safe access to hardware information
- Documents hardware capabilities explicitly

**Example**:
```nix
# lib/hardware.nix
let
  parseFacter = facterPath: {
    cpu = extractCPUInfo facterPath;
    gpu = extractGPUInfo facterPath;
    memory = extractMemoryInfo facterPath;
    storage = extractStorageInfo facterPath;
    network = extractNetworkInfo facterPath;
  };

# hosts/zephyrus/meta.nix
let
  hw = parseFacter ./zephyrus-facter.json;
in {
  boot.kernelModules = hw.cpu.modules ++ hw.gpu.modules ++ hw.storage.modules;
  # ...
}
```

**Alternatives considered**:
- **Direct JSON parsing in meta.nix**: Rejected - duplicates logic, error-prone
- **Manual transcription**: Current approach - error-prone, incomplete
- **Auto-generation**: Rejected - reduces flexibility, harder to customize

### Terminal Multiplexer Choice

**Decision**: Use zellij as the terminal multiplexer

**Rationale**:
- Written in Rust, modern and performant
- Excellent keyboard-driven workflow
- Good defaults out of the box
- Active development and community
- Works well with Wayland (important for niri/ghostty stack)

**Configuration approach**:
- Opt-in (not forced on users)
- Sensible defaults provided
- Integration with fish shell via aliases
- Documentation for common workflows

**Alternatives considered**:
- **tmux**: Traditional choice, but more configuration needed for modern UX
- **screen**: Outdated, limited features
- **No multiplexer**: Current state - limits productivity

### DevShell Enhancement Strategy

**Decision**: Comprehensive tooling grouped by function

**Rationale**:
- Reduces friction for common development tasks
- Self-documenting through tool presence
- Minimal overhead (dev tools, not runtime)
- Aligns with Nix ecosystem best practices

**Tool categories**:
1. **Nix language support**: nil, nixd, formatters
2. **NixOS operations**: rebuild helpers, validation
3. **Code quality**: statix, deadnix, shellcheck
4. **Documentation**: manix, nix-doc
5. **Analysis**: nix-diff, nix-du, nix-info
6. **Discovery**: nix-index, nix-tree

**Alternatives considered**:
- **Minimal shell**: Current state - requires manual tool installation
- **Per-project shells**: Rejected - duplicates common tools
- **System-wide installation**: Rejected - pollutes system, hard to version

## Technical Approach

### Module Refactoring Process

1. **Analyze** current module to identify logical boundaries
2. **Create** subdirectory with module name
3. **Split** into focused files (one concern per file)
4. **Update** main module to import split components
5. **Test** that functionality is preserved
6. **Commit** with clear description of split

Target modules:
- `modules/desktop-shells/dankmaterial/widgets.nix` (407 lines → ~8 focused modules + 1 aggregator)
- `modules/desktop-shells/dankmaterial/services.nix` (333 lines → ~6 focused modules + 1 aggregator)
- `modules/home-manager/dotfiles/opencode-ai.nix` (275 lines → ~4 focused modules + 1 aggregator)

Note: Split files will include necessary imports and structure, so total lines may slightly exceed original due to module overhead.

### Facter Integration Process

1. **Create** `lib/hardware.nix` with parsing functions
2. **Extract** each hardware category (CPU, GPU, memory, storage, network)
3. **Update** meta.nix files to use parsed data
4. **Document** hardware detection patterns
5. **Test** on all hosts (zephyrus, yoga, hetzner-vps)

### Zellij Integration Process

1. **Add** zellij package to home-manager
2. **Create** default configuration in home directory
3. **Configure** keybindings for common operations
4. **Create** layout templates for common workflows
5. **Add** fish aliases for quick access
6. **Document** usage and workflows

### DevShell Enhancement Process

1. **Categorize** tools by function
2. **Add** tools to flake.nix devShells.default
3. **Create** welcome message script
4. **Configure** shell aliases
5. **Add** shell prompt customization
6. **Document** available tools and usage

## Risks and Trade-offs

### Risk: Module refactoring breaks imports

**Mitigation**: 
- Main module files remain as aggregators
- All existing imports continue to work
- Test builds after each refactoring step

### Risk: Facter data parsing complexity

**Mitigation**:
- Start with simple extractions (CPU, GPU)
- Add complexity incrementally
- Provide fallbacks for missing data
- Document expected facter.json structure

### Risk: DevShell closure size increase

**Impact**: Development shell will download more packages
**Mitigation**: 
- Tools are dev-time only, not in system closure
- Benefits (productivity) outweigh costs (disk/download)
- Can be selective about tools if needed

### Trade-off: More files vs. easier navigation

**Decision**: Favor more files (better organization)
**Rationale**: Modern editors handle many files well, benefits clarity

## Migration Plan

This change is fully backward compatible, no migration needed:

1. Module refactoring maintains import compatibility
2. Hardware detection enhances existing meta.nix (no breaking changes)
3. Zellij is opt-in (doesn't replace anything)
4. DevShell enhancement is additive (existing tools remain)

## Testing Strategy

1. **Build tests**: Verify all hosts build successfully after changes
2. **Functional tests**: Manually verify refactored components work
3. **Integration tests**: Test zellij with shell and terminal
4. **DevShell tests**: Verify all tools available and functional

## Open Questions

1. Should zellij be auto-started in terminals? **Decision**: No, opt-in via alias
2. Should pre-commit hooks be added? **Decision**: Future enhancement, not in initial scope
3. Should facter.json parsing be automatic or explicit? **Decision**: Explicit in meta.nix
4. Should module size limit be enforced? **Decision**: Guideline (250 lines of code), not strict rule
5. Should line count include comments/blanks? **Decision**: No, count code lines only

## Success Criteria

1. All modules under 250 lines (except aggregators)
2. meta.nix files utilize all relevant facter.json data
3. Zellij configured and documented
4. DevShell has all planned tools
5. All hosts build successfully
6. No functionality lost in refactoring
7. Documentation complete and accurate
