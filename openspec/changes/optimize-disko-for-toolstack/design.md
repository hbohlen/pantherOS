# Optimize Disko for Specific Toolstack - Design

## Architectural Overview

The system will implement a toolstack-aware disko.nix generator that analyzes the specified tools and workloads on a host and generates optimized btrfs configurations accordingly. The architecture consists of modules for toolstack analysis, I/O pattern recognition, and configuration generation.

## Components

### 1. Toolstack Analyzer
- Parses user-provided list of tools and services running on the host
- Categorizes tools into workload types (IDEs, browsers, databases, containers, build systems)
- Determines specific requirements for each tool category
- Outputs a structured profile of the host's workload characteristics

### 2. I/O Pattern Database
- Contains pre-defined I/O patterns for common tools and services
- Maps tools to their typical read/write ratios, file size patterns, and access characteristics
- Includes performance optimization recommendations for each tool type
- Provides guidance on compressibility of tool-related data

### 3. Subvolume Layout Optimizer
- Creates optimal btrfs subvolume layouts based on toolstack profile
- Determines appropriate separation boundaries between different tool categories
- Positions frequently accessed data for optimal performance
- Considers space requirements and growth patterns

### 4. Mount Option Generator
- Generates appropriate mount options for each subvolume based on its purpose
- Applies compression settings optimized for the expected file types
- Sets performance-related options based on access patterns
- Configures snapshot-related options for data durability requirements

### 5. Configuration Validator
- Validates generated disko.nix configurations against best practices
- Checks for configuration conflicts or impossible setups
- Provides feedback on potential performance bottlenecks
- Ensures generated configurations are compatible with disko

## Data Flow

1. Input: List of tools and services, project directories, workload characteristics
2. Toolstack Analysis: Identify tool types and workload patterns
3. I/O Pattern Matching: Map tools to known I/O behaviors
4. Layout Generation: Create optimized subvolume structure
5. Mount Option Selection: Apply appropriate mount options per subvolume
6. Validation: Verify configuration is valid and optimal
7. Output: Generate disko.nix configuration with documentation

## Key Algorithms

### Toolstack Classification
- For IDEs/editors: High read/write ratio, many small files, compressible content
- For browsers: Cache-heavy, mixed file sizes, frequent updates
- For containers (Podman): High I/O, many small random writes, sensitive to CoW
- For databases: Consistent write patterns, durability requirements, specific access patterns
- For build systems: Temporary files, high I/O bursts, compressible output

### Subvolume Separation Strategy
- Separate project directories for independent snapshot management
- Isolate volatile cache data from persistent configuration
- Group related tools in appropriate subvolumes based on access patterns
- Consider space requirements and growth patterns for separation decisions

### Mount Option Selection
- For project/source code: compress=zstd for high compression ratio, noatime for read performance
- For build caches: compress=zstd, autodefrag for frequently modified files
- For databases: compress=no, nodatacow for performance and durability
- For containers: nodatacow, compress=no if performance is priority; compress=zstd if space is priority

## Technology Stack

- Nix/NixOS for configuration management and domain-specific language
- Standard Nixpkgs libraries for data processing and utility functions
- Disks for disk configuration (existing dependency in the project)
- Nix's built-in JSON processing capabilities for configuration handling
- Standard NixOS modules for disko.nix generation

## Implementation Patterns

### Configurable Tool Categories
- Define tool categories with known I/O characteristics
- Allow for toolstack customizations and extensions
- Maintain backwards compatibility with existing configurations

### Performance vs Reliability Trade-offs
- Document trade-offs for each configuration choice
- Provide guidelines for production vs development environments
- Allow configuration of optimization priorities

## Toolstack-Specific Optimizations

### IDE and Editor Optimization
- Subvolumes with compress=zstd for source code (highly compressible)
- noatime option to reduce write overhead on read-heavy operations
- autodefrag to help with frequently modified files during development
- Separate subvolumes for IDE configuration to allow for consistent snapshots

### Browser Optimization
- Dedicated subvolumes for browser profiles and cache data
- Appropriate compression settings for different types of web content
- Consideration for IndexedDB and other browser storage mechanisms
- Isolation of cache data from core system to prevent unneeded snapshots

### Container Runtime Optimization
- For Podman/docker: nodatacow option for better container performance
- Separate subvolumes for images, containers, and volumes
- Appropriate mount options for overlay filesystems
- Compression disabled for container layers that are already compressed

### Database Optimization
- For PostgreSQL/MySQL: mount options prioritizing durability
- For SQLite: optimized for mixed read/write patterns
- Consideration for WAL (Write-Ahead Logging) files
- Potential use of nodatacow for performance-critical databases

### Build System Optimization
- Subvolumes for build caches with appropriate retention policies
- Optimized for temporary files and build artifacts
- Consideration for nix build sandboxes and temporary directories
- Isolation of build artifacts from source code

## Mount Option Strategy per Toolstack

### Development Workloads Priority
- Prioritize responsiveness and quick access
- Aggressive compression for source code and build artifacts
- Frequent backup/snapshot strategies for code
- Options like `autodefrag` for build caches that see many small writes

### Production Workloads Priority
- Prioritize reliability and data integrity
- Conservative compression settings where needed for performance
- Consistent snapshot strategies for recovery
- Options that ensure data durability over performance when needed