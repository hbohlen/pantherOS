# Analyze Asus ROG Zephyrus Hardware and Generate Optimized Subvolume Layout - Design

## Architectural Overview

The system will implement a hardware analysis and optimization framework specifically for the Asus ROG Zephyrus laptop with its dual NVMe configuration. The architecture includes modules for hardware analysis, workload pattern recognition, and optimized subvolume layout generation.

## Components

### 1. Hardware Analyzer
- Parses the facter.json file to identify storage devices and their characteristics
- Identifies device paths (nvme0n1, nvme1n1) and storage capacities
- Determines which disk is the Crucial P3 2TB and which is the Micron 2450 1TB
- Extracts NVMe controller details and supported features

### 2. Workload Analyzer
- Analyzes I/O patterns for Zed IDE, including cache and project directory usage
- Examines Podman container image and volume patterns
- Evaluates browser cache behavior for Vivaldi
- Assesses Git repository access patterns in ~/dev directory

### 3. Drive Characteristic Evaluator
- Compares performance and endurance characteristics of Crucial P3 vs Micron 2450
- Determines optimal allocation based on workload requirements
- Considers factors like random read performance, write endurance, and thermal management

### 4. Layout Generator
- Creates optimized subvolume layout based on hardware and workload analysis
- Plans placement of system and user components on appropriate drives
- Generates ASCII diagrams and detailed layout documentation

### 5. Mount Options Optimizer
- Applies appropriate mount options for different data types and performance requirements
- Considers compression settings based on data characteristics
- Balances performance and data safety requirements

### 6. Backup Strategy Designer
- Creates snapshot strategy specific to development laptop usage
- Develops backup procedures for code and project data
- Plans retention policies based on data criticality and available space

## Data Flow

1. Input: facter.json file for the Zephyrus laptop
2. Hardware Analysis: Extract storage device characteristics
3. Workload Analysis: Analyze development usage patterns
4. Drive Evaluation: Compare Crucial P3 vs Micron 2450 characteristics
5. Layout Design: Generate optimized subvolume layout
6. Mount Options: Apply optimized mount settings
7. Backup Strategy: Create snapshot and backup plan
8. Output: Documentation with layout diagram, mount options matrix, and backup strategy

## Key Algorithms

### Drive Assignment Logic
- Primary drive (Crucial P3 2TB): System files, home directory, Zed IDE data
- Secondary drive (Micron 2450 1TB): Podman containers, high-I/O project data
- Consideration factors: endurance, performance, capacity requirements

### Subvolume Separation Strategy
- System components (@root, @nix, @log): Primary drive for better performance
- User data (@home, @config, @local): Primary drive for accessibility
- Development projects (@dev): Primary drive with potential for overflow to secondary
- Container storage (@containers): Secondary drive to isolate I/O patterns
- Caches and temporary data (@user-cache, @tmp): Appropriate drives based on access patterns

## Technology Stack

- Nix/NixOS for configuration management and domain-specific language
- Standard Nixpkgs libraries for data processing and utility functions
- Hardware detection utilities for facter.json analysis
- btrfs-progs for subvolume management
- Standard NixOS modules for disko.nix generation

## Implementation Patterns

### Performance-Optimized Placement
- Place frequently accessed system files on higher-performance drive
- Separate I/O intensive workloads to avoid interference
- Consider thermal impact of high-I/O operations

### Development-Centric Design
- Optimize for common development workflows
- Prioritize fast access to project files and IDE caches
- Ensure reliable container operations for testing

## Drive-Specific Optimizations

### Crucial P3 2TB (Primary Drive)
- Higher capacity for system files and user data
- Sufficient endurance for OS and IDE usage
- Faster sequential performance for system operations

### Micron 2450 1TB (Secondary Drive)
- Good random read performance for container operations
- Sufficient capacity for container images and volumes
- Dedicated I/O path to avoid interference with primary operations

## Workload-Specific Considerations

### Zed IDE Optimization
- Fast access to project directories for responsive editing
- Efficient caching of large project indexes
- Appropriate compression for text files in code projects

### Podman Container Optimization
- Dedicated subvolume for container storage
- nodatacow for performance (if appropriate)
- Isolated from other I/O patterns for predictable performance

### Git Repository Optimization
- Appropriate mount options for frequent small file access
- Consider compression for text-heavy repositories
- Efficient snapshot strategy for code history

## Mount Options Strategy

### System Subvolumes
- @root: compress=zstd:3, noatime, space_cache=v2
- @nix: compress=zstd:1, noatime, space_cache=v2 (for many similar files)
- @log: compress=zstd:3, noatime, space_cache=v2 (logs compress well)

### User Subvolumes
- @home: compress=zstd:3, noatime, space_cache=v2
- @dev: compress=zstd:3, noatime, space_cache=v2 (source code compresses well)

### Container Subvolumes
- @containers: nodatacow, compress=no, noatime (for overlayfs performance)

## Backup and Snapshot Strategy

### Development Laptop Specifics
- More frequent snapshots of ~/dev directory
- Longer retention for critical code projects
- Efficient snapshot strategy for container data
- Portable backup strategy considering laptop mobility