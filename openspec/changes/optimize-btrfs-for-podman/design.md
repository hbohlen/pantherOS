# Optimize Btrfs for Podman Containers - Design

## Architectural Overview

The system will implement a specialized configuration generator for btrfs storage optimized for Podman containers. The architecture includes components for analyzing container workloads, determining optimal storage strategies, and generating appropriate disko.nix configurations with proper subvolume layouts and mount options.

## Components

### 1. Container Workload Analyzer
- Parses user-provided information about expected container count, size, and types
- Categorizes workloads (APIs, databases, short-lived jobs, etc.)
- Determines storage requirements based on container characteristics
- Outputs workload profile for configuration generation

### 2. Storage Driver Evaluator
- Analyzes trade-offs between overlay2 on btrfs vs direct btrfs subvolumes
- Evaluates performance impact of different storage approaches
- Considers snapshot and backup implications of each approach
- Provides recommendations based on workload characteristics

### 3. Subvolume Layout Generator
- Creates optimal btrfs subvolume layouts for container storage
- Separates container images, volumes, and temporary data appropriately
- Considers snapshot and performance requirements for each separation
- Designs layouts that facilitate efficient container management

### 4. Mount Option Optimizer
- Determines appropriate mount options for different container storage needs
- Applies appropriate compression settings for container images vs volumes
- Decides where to use nodatacow based on performance requirements
- Optimizes for specific container I/O patterns

### 5. Configuration Validator
- Validates generated disko.nix configurations for container-specific best practices
- Checks for configuration conflicts or performance issues
- Ensures generated configurations are compatible with Podman requirements
- Provides feedback on potential improvements

## Data Flow

1. Input: Container workload specifications (counts, sizes, types, expected driver)
2. Workload Analysis: Categorize and profile container workloads
3. Storage Strategy Determination: Select optimal storage approach
4. Layout Generation: Create subvolume structure for containers
5. Mount Option Selection: Apply appropriate options for each subvolume
6. Validation: Ensure configuration meets container storage best practices
7. Output: Generate optimized disko.nix configuration with documentation

## Key Algorithms

### Storage Driver Selection
- For high-performance, many-small-file workloads: Consider direct btrfs subvolumes
- For standard container workloads: overlay2 on btrfs is typically optimal
- For snapshot-heavy workloads: overlay2 allows for efficient layer snapshots
- For performance-critical workloads: consider nodatacow options

### Subvolume Separation Strategy
- Separate /var/lib/containers for centralized container storage management
- Isolate container volumes if they require different retention policies
- Consider separate subvolumes for different container types (stateful vs stateless)

### Mount Option Selection
- For container images (in /var/lib/containers): nodatacow and compress=no for performance
- For container volumes: depends on volume content (databases vs files vs temp)
- For logs: standard compression and performance options

## Technology Stack

- Nix/NixOS for configuration management and domain-specific language
- Standard Nixpkgs libraries for data processing and utility functions
- Disks for disk configuration (existing dependency in the project)
- Podman for container runtime integration (existing dependency)
- Standard NixOS modules for disko.nix generation

## Implementation Patterns

### Configurable Storage Strategies
- Define different storage strategies for various container use cases
- Allow for customization based on specific performance or reliability needs
- Maintain compatibility with existing container infrastructure

### CoW vs nodatacow Trade-offs
- Document performance implications of each approach
- Provide guidelines for when to use each option
- Consider backup and snapshot implications

## Podman-Specific Optimizations

### Overlay2 on Btrfs Considerations
- Btrfs CoW features can enhance overlay2 performance
- Snapshot functionality works well with layered container images
- Careful mount option selection is important for performance

### Direct Btrfs Subvolumes
- Potential for better performance in specific scenarios
- More complex management requirements
- Different snapshot behavior compared to overlay2

### Container Volume Management
- Dedicated subvolumes for persistent data with appropriate options
- Temporary storage optimization for ephemeral containers
- Backup strategy considerations for different volume types

## Performance vs Reliability Trade-offs

### Performance Priorities
- Use nodatacow for container storage to avoid double CoW overhead
- Disable compression for already-compressed container images
- Optimize for I/O patterns typical of container workloads

### Reliability Priorities
- Maintain snapshot capability for container data recovery
- Ensure proper journaling and data integrity settings
- Consider backup strategies for container volumes