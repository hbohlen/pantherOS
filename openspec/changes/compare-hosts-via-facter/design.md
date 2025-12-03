# Compare Hosts via Facter - Design

## Architectural Overview

The system will implement a comparison tool that analyzes two facter.json files and generates host-specific disko.nix strategies based on hardware differences and workload requirements. The architecture is designed as a modular system with distinct components for hardware analysis, comparison, and configuration generation.

## Components

### 1. Hardware Comparison Engine
- Parses and analyzes facter.json files from both hosts using Nix's built-in JSON capabilities
- Identifies differences in CPU (architecture, cores, performance characteristics), RAM (size, speed, configuration), storage (type, capacity, performance), and virtualization properties
- Evaluates hardware specifications against known best practices for storage optimization
- Returns a structured comparison report highlighting meaningful differences

### 2. Workload Profile Analyzer
- Assesses workload descriptions provided by the user for each host
- Categorizes workloads (development vs production, containers vs databases vs general use, I/O intensive vs compute intensive)
- Maps workload types to appropriate storage strategies considering the hardware profile
- Outputs workload-based optimization parameters for disko generation

### 3. Hardware Profiler
- Extracts relevant hardware characteristics from facter.json files
- Categorizes storage devices by type (NVMe, SATA SSD, HDD, virtual disk, etc.)
- Determines storage performance capabilities and limitations
- Assesses available RAM for potential zram/zswap optimizations

### 4. Disko Strategy Generator
- Creates btrfs subvolume layouts optimized for each host's specific hardware profile and workload requirements
- Determines mount options based on storage type (NVMe vs SATA SSD vs HDD vs virtual disk) and workload characteristics
- Defines snapshot and backup strategies based on reliability requirements and available storage capacity
- Generates disko.nix configuration with appropriate abstractions for maintainability

### 5. Strategy Validation Module
- Validates generated disko configurations against hardware constraints
- Checks for configuration conflicts or impossible setups
- Provides feedback and suggestions for configuration improvements

## Data Flow

1. Input: Two facter.json files and workload descriptions (dev vs prod, containers vs DB vs general use)
2. Hardware Profiling: Extract hardware characteristics from both facter.json files
3. Comparison: Identify differences in CPU, RAM, storage, virtualization between hosts
4. Workload Analysis: Categorize workload types and requirements
5. Strategy Generation: Create optimized disko.nix configurations for each host based on hardware+workload profile
6. Validation: Verify generated configurations are valid and appropriate
7. Output: Host-specific disko.nix configurations with documentation of decisions made

## Key Algorithms

### Hardware Difference Detection
- Compare CPU cores count, architecture (x86_64 vs ARM), generation, and performance characteristics
- Evaluate RAM size, speed, and configuration (single vs dual channel, etc.)
- Assess storage type (NVMe vs SATA SSD vs HDD vs virtual disk), capacity, and performance characteristics
- Identify virtualization capabilities (none vs KVM vs VMware vs VirtualBox, etc.)
- Determine form factor (laptop vs desktop vs server) and its implications

### Storage Strategy Selection
- For NVMe storage: Optimize for high IOPS with fewer, larger subvolumes and performance-focused mount options (noatime, compress=zstd)
- For SATA SSDs: Balance performance with isolation using moderate number of subvolumes and balanced mount options
- For HDDs: Maximize I/O efficiency with appropriate subvolume layout and mount options that reduce seeks
- For multi-storage systems: Distribute subvolumes strategically based on storage characteristics (apps on fast storage, data on large storage)

### Mount Option Matrix
- Root subvolumes: compress=zstd, noatime for performance and data efficiency
- Home subvolumes: compress=zstd, space_cache=v2 for user data efficiency
- Nix store: compress=no, noatime for performance (as Nix already has compression and deduplication)
- Var subvolumes: compress=no for performance, with appropriate CoW settings based on use (databases vs logs)
- Boot/efi: Not on btrfs (separate partition) or with nodatacow for reliability

## Technology Stack

- Nix/NixOS for configuration management and domain-specific language
- Standard Nixpkgs libraries for data processing, JSON parsing, and utility functions
- Facter for hardware detection (existing dependency in the project)
- Disks for disk configuration (existing dependency in the project)
- Nix's built-in JSON parsing capabilities for facter.json processing
- Standard NixOS modules for disko.nix generation

## Implementation Patterns

### Modular Design
- Separate modules for each component to allow independent testing and reuse
- Clear interfaces between components with well-defined inputs and outputs
- Configuration functions that can be composed together

### Hardware Profiling Pattern
- Abstract hardware characteristics into a consistent interface regardless of source
- Use pattern matching to identify hardware categories and capabilities
- Normalize different representation formats from facter.json

### Strategy Generation Pattern
- Use hardware profile + workload profile to select from a catalog of pre-defined strategies
- Apply configuration transformations based on specific constraints
- Maintain documentation of why each decision was made

## Trade-offs Considered

### Performance vs Complexity
- Simple configurations are easier to debug and maintain but may not be perfectly optimized
- Complex configurations can provide better performance but are harder to understand
- Solution: Provide baseline configurations with optional advanced optimizations

### Flexibility vs Opinionated Design
- Flexible systems allow more customization but require more user knowledge
- Opinionated systems are easier to use but might not suit all use cases
- Solution: Provide sensible defaults based on hardware profile with clear extension points