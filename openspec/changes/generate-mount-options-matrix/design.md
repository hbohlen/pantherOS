# Generate Mount Options Matrix for All Planned Subvolumes - Design

## Architectural Overview

The system will implement a standardized matrix generator for btrfs mount options that provides systematic recommendations based on subvolume purpose, host type, and workload profile. The architecture includes components for analyzing subvolume requirements, determining appropriate mount options, and generating documented matrices with clear rationales for each decision.

## Components

### 1. Subvolume Analyzer
- Parses list of planned subvolumes with names, mountpoints, and purposes
- Classifies subvolumes into categories (system, user, development, container, database, etc.)
- Determines host type characteristics (laptop, server, VPS)
- Profiles workload requirements (development, production, etc.)

### 2. Mount Option Decision Engine
- Evaluates appropriate mount options based on subvolume purpose and host characteristics
- Considers performance, reliability, and space efficiency requirements
- Makes nodatacow vs CoW decisions based on specific criteria
- Determines compression settings based on data type and requirements

### 3. Matrix Generator
- Creates standardized table format with consistent structure
- Populates recommended values for each mount option
- Documents rationale for each decision
- Highlights special cases and considerations

### 4. Documentation Generator
- Creates detailed rationales for each mount option decision
- Explains performance and safety implications
- Documents trade-offs for each choice
- Provides references to relevant documentation

### 5. Validation Module
- Validates generated matrices against best practices
- Checks for conflicting mount option combinations
- Ensures consistency across similar subvolume types
- Provides feedback on potential improvements

## Data Flow

1. Input: List of subvolumes (name + mountpoint + purpose), host type, workload profile
2. Subvolume Analysis: Categorize and profile each subvolume
3. Mount Option Determination: Decide appropriate mount options per subvolume
4. Matrix Generation: Create standardized table with recommendations
5. Documentation: Add rationales and implications for each decision
6. Validation: Check against best practices and consistency rules
7. Output: Generate complete mount options matrix with documentation

## Key Algorithms

### Mount Option Selection Logic
- For system files: Good compression (zstd:3), noatime, space_cache=v2, discard=async
- For database files: nodatacow, compress=no, safety-focused options
- For container storage: nodatacow, compress=no, performance-focused
- For user data: Medium compression (zstd:2-3), standard performance options
- For logs: Good compression (zstd:3), consider noatime
- For temporary files: compress=no or light compression, speed-focused

### Compression Strategy
- High compression (zstd:3): Source code, configs, text files, logs
- Medium compression (zstd:2): Mixed content, binaries
- Light compression (zstd:1): Frequently modified files
- No compression (compress=no): Already compressed data (images, videos), databases, temporary files

### Special Case Detection
- Detect database directories and recommend nodatacow and no compression
- Identify container storage paths for performance optimization
- Recognize log and cache directories for appropriate settings
- Flag temporary directories for specific optimization

## Technology Stack

- Nix/NixOS for configuration management and domain-specific language
- Standard Nixpkgs libraries for data processing and utility functions
- Disks for disk configuration (existing dependency in the project)
- Standard NixOS modules for disko.nix generation

## Implementation Patterns

### Standardized Table Format
- Consistent column structure across all matrices
- Clear labeling of subvolume categories
- Standardized rationale format

### Decision Transparency
- Document all decision rationales clearly
- Explain performance vs safety trade-offs
- Provide justification for special cases

## Mount Option Categories

### Compression
- compress=zstd:X (where X is 1, 2, 3 for different levels)
- compress=no for already compressed data
- Selection based on data type and access patterns

### Performance Options
- noatime to reduce write overhead from access time updates
- space_cache=v2 for efficient space usage tracking
- autodefrag for frequently modified files

### Reliability Options
- nodatacow for databases and other performance-critical applications
- discard=async for TRIM support on SSDs
- Standard CoW behavior for most general-purpose data

## Host Type Considerations

### Laptop
- Battery life considerations (aggressive TRIM management)
- Portability requirements (snapshot strategies)
- I/O patterns (mixed usage patterns)

### Server
- Performance optimization (consistent I/O patterns)
- Reliability priorities (consistent snapshot strategies)
- Density requirements (efficient storage utilization)

### VPS
- Virtualization overhead considerations
- Limited I/O resources optimization
- Cost efficiency priorities (space efficiency)

## Special Case Handling

### Database Subvolumes
- Use nodatacow for performance reasons
- Disable compression for already compact data
- Prioritize durability and consistency over space efficiency

### Container Storage
- nodatacow for container image performance
- compress=no since images are already compressed
- Performance-focused options to avoid I/O overhead

### Log and Cache Directories
- Appropriate compression levels for frequently modified data
- Consider autodefrag for frequently changing files
- Balance snapshot requirements with performance

### Temporary Directories
- Speed-focused over space efficiency
- compress=no or light compression
- Minimal durability requirements for performance