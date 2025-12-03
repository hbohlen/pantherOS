# Recommend Optimal Btrfs Compression Settings Per Subvolume - Design

## Architectural Overview

The system will implement a compression recommendation engine that analyzes host hardware and subvolume data types to suggest optimal btrfs compression settings. The architecture includes components for hardware analysis, data type classification, compression analysis, and recommendation generation, with a focus on balancing CPU cost, performance, and disk usage.

## Components

### 1. Hardware Profiler
- Extracts CPU information from facter.json (core count, type, architecture)
- Evaluates available computational resources for compression tasks
- Determines appropriate compression levels based on processing capabilities
- Outputs hardware profile for recommendation engine

### 2. Data Type Classifier
- Analyzes data types in each subvolume (source code, databases, logs, container images, etc.)
- Determines compressibility characteristics for different file types
- Classifies subvolumes by data type and access patterns
- Provides data profile for recommendation engine

### 3. Compression Analyzer
- Evaluates different zstd compression levels (1, 3, 6) for CPU vs compression trade-offs
- Estimates compression ratios by data type
- Calculates expected CPU overhead for different compression levels
- Generates compression effectiveness metrics

### 4. Recommendation Engine
- Combines hardware profile and data type classifications to generate recommendations
- Makes explicit decisions on when to disable compression entirely
- Balances performance requirements with space efficiency goals
- Provides reasoning for each recommendation

### 5. Estimation Module
- Calculates expected effective capacity gains from compression strategy
- Estimates performance impacts of different compression levels
- Provides capacity planning information
- Computes cost-benefit analysis for compression strategies

## Data Flow

1. Input: facter.json data, list of subvolumes with mountpoints and purposes
2. Hardware Analysis: Extract CPU capabilities from facter.json
3. Data Classification: Identify data types in each subvolume
4. Compression Analysis: Evaluate trade-offs between compression levels
5. Recommendation Generation: Create per-subvolume compression recommendations
6. Estimation: Calculate effective capacity gains and performance impacts
7. Output: Recommendations with levels, reasons, and capacity projections

## Key Algorithms

### CPU vs Compression Trade-off Analysis
- For high-core count systems: Higher compression levels (zstd:3, zstd:6) may be viable
- For low-power systems: Lower compression levels (zstd:1) to reduce CPU overhead
- Consider CPU architecture (x86_64, ARM) for performance optimization

### Data Type Specific Compression Strategies
- Text-heavy data (source code, configs, logs): High compression (zstd:3) - excellent ratios
- Database files: Medium compression (zstd:1) or none (nodatacow) - depends on DB engine
- Container images: Often disable compression (compress=no) - already compressed
- Binary artifacts: Medium compression (zstd:1, zstd:2) - moderate ratios
- Media files: Disable compression (compress=no) - already compressed

### Compression Ratio Expectations
- Source code/configs: ~50-70% space reduction with zstd:3
- Log files: ~60-80% space reduction with zstd:3
- Text documents: ~60-80% space reduction with zstd:3
- Database files: ~10-30% space reduction depending on content
- Container images: ~5-15% additional reduction with compression
- Compressed media: ~0-5% space reduction

## Technology Stack

- Nix/NixOS for configuration management and domain-specific language
- Standard Nixpkgs libraries for data processing and utility functions
- Disks for disk configuration (existing dependency in the project)
- Standard NixOS modules for disko.nix integration
- Existing hardware detection utilities

## Implementation Patterns

### Decision Transparency
- Clearly document why each compression level was recommended
- Explain trade-offs between CPU usage and space savings
- Provide alternatives when appropriate

### Configurable Thresholds
- Allow customization of compression level thresholds
- Enable different profiles based on performance vs space priorities
- Support manual override options for special cases

## Compression Level Selection Framework

### zstd:1 (Fast/Light Compression)
- CPU overhead: Low
- Space savings: Moderate
- Use case: Frequently-changing files, binary data with low compressibility
- Example: Binary artifacts, system cache, frequently modified files

### zstd:3 (Balanced Compression)
- CPU overhead: Moderate
- Space savings: Good
- Use case: General-purpose text data, moderate compressibility
- Example: Source code, configuration files, general user data

### zstd:6 (High Compression)
- CPU overhead: Higher
- Space savings: Excellent
- Use case: Highly-compressible data where space is critical
- Example: Archive data, highly repetitive text, log files

### compress=no (No Compression)
- CPU overhead: None
- Space savings: None
- Use case: Already compressed data, performance-critical applications
- Example: Media files, database files, container images, swap space

## Host Type Considerations

### Laptop/Development Systems
- Balance performance and space efficiency
- Consider battery life impact of CPU-intensive compression
- Prioritize responsiveness over maximum compression

### Production Servers
- Weight space efficiency heavily due to storage costs
- May accept higher CPU overhead for better space utilization
- Consider overall system load and resource availability

### Resource-Constrained Systems
- Minimize CPU overhead from compression
- Use lower compression levels or disable compression where practical
- Focus on maximum compatibility and stability

## Special Case Handling

### Database Files
- Consider database engine requirements (some perform better with no compression)
- Account for write amplification in transactional systems
- Balance compression benefit against database performance requirements

### Container Images
- Typically disable compression as images are already compressed
- Consider overlayfs interaction with btrfs CoW
- Evaluate specific storage driver implications

### Log and Temporary Files
- High compression for log files due to excellent compression ratios
- Consider disabling for very frequently written temporary data
- Account for access patterns and rotation strategies

### System Performance Monitoring
- Monitor actual compression performance vs expectations
- Track CPU usage from compression tasks
- Verify actual space savings against projections