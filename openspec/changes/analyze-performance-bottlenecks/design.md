# Analyze Performance Bottlenecks and Tuning Recommendations - Design

## Architectural Overview

The system will implement a diagnostic and optimization framework for btrfs storage performance issues. The architecture includes modules for collecting and analyzing system metrics, identifying various types of bottlenecks, and generating targeted recommendations while considering real-world constraints like existing deployments and hardware limitations.

## Components

### 1. Metrics Ingestion Module
- Parses facter.json to understand hardware capabilities (CPU, RAM, storage type, etc.)
- Interprets current disko.nix configuration including subvolume layout and mount options
- Processes system metrics (df output, btrfs usage, iostat/iotop if available)
- Collects user-reported performance observations

### 2. Bottleneck Analyzer
- Identifies hardware-related performance bottlenecks (slow storage, insufficient RAM, etc.)
- Detects subvolume layout inefficiencies (improper separation, suboptimal groupings)
- Evaluates mount option appropriateness for specific workloads
- Assesses compression level effectiveness vs overhead

### 3. Workload Pattern Identifier
- Recognizes specific slow paths (IDE builds, DB writes, container I/O, etc.)
- Correlates user-reported slowness with system configuration
- Categorizes performance issues by type and severity
- Maps observed behaviors to likely root causes

### 4. Recommendation Engine
- Generates mount option changes based on identified bottlenecks
- Suggests subvolume layout adjustments (merging or splitting)
- Recommends kernel/sysctl tunables for performance improvement
- Prioritizes recommendations by expected impact vs disruption

### 5. Impact Estimator
- Calculates before/after performance expectations
- Provides realistic projections based on hardware limitations
- Considers workload profiles in estimating improvements
- Accounts for potential negative effects of changes

### 6. Non-Disruptive Change Selector
- Prioritizes changes that don't require system reinstallation
- Identifies mount option modifications that can be applied live
- Suggests btrfs-specific optimizations that can be implemented gradually
- Flags changes that require downtime or reformatting

## Data Flow

1. Input: facter.json, current disko.nix, system metrics (df, btrfs usage), user observations
2. Hardware Analysis: Extract and evaluate hardware capabilities
3. Configuration Analysis: Parse current disko.nix and mount options
4. Performance Observation Analysis: Process reported performance issues
5. Bottleneck Identification: Match symptoms with potential root causes
6. Recommendation Generation: Create targeted fixes for identified issues
7. Impact Estimation: Calculate expected performance improvements
8. Output: Diagnoses, recommendations, and before/after expectations

## Key Algorithms

### Hardware Bottleneck Detection
- Compare reported performance issues with hardware capabilities
- Identify if storage type (HDD vs SSD vs NVMe) matches expected workloads
- Evaluate if RAM is sufficient for buffering and cache requirements
- Assess CPU performance in relation to compression workloads

### Subvolume Layout Inefficiency Detection
- Identify subvolumes with incompatible I/O patterns that should be separated
- Find opportunities to merge subvolumes with similar access patterns
- Detect subvolumes that would benefit from different mount options
- Evaluate snapshot strategies for performance impact

### Mount Option Optimization
- Adjust compression levels based on data type and performance requirements
- Enable/disable specific fs options (noatime, autodefrag, etc.) based on usage
- Apply nodatacow settings appropriately for databases and containers
- Tune discard and space_cache options based on storage characteristics

## Technology Stack

- Nix/NixOS for configuration analysis and domain-specific language
- Standard Nixpkgs libraries for data processing and parsing utilities
- Existing hardware detection utilities for facter.json analysis
- System monitoring tools (iotop, iostat, btrfs utilities) for metric analysis
- Standard NixOS modules for performance analysis

## Implementation Patterns

### Graduated Recommendations
- Start with low-risk, high-impact recommendations
- Progress to more involved changes as needed
- Prioritize non-disruptive changes over those requiring reinstallation

### Evidence-Based Diagnostics
- Correlate user observations with system characteristics
- Use metrics to support or refute potential bottlenecks
- Account for multiple contributing factors to performance issues

### Realistic Expectations
- Base performance projections on actual hardware capabilities
- Account for diminishing returns on multiple optimizations
- Consider worst-case scenarios where bottlenecks are hardware-bound

## Performance Issue Categories

### Slow Builds (Development Workloads)
- Symptoms: Slow compilation, dependency downloads, package installation
- Causes: Suboptimal compression for binary artifacts, inappropriate mount options
- Solutions: Adjust compression levels, fine-tune cache-related options

### Slow Database Operations
- Symptoms: Slow write performance, high I/O latency
- Causes: CoW overhead, inappropriate mount options for database files
- Solutions: Apply nodatacow, adjust caching behavior, optimize for write patterns

### Slow Container I/O
- Symptoms: Slow container startup, slow image pulls, slow volume operations
- Causes: CoW overhead in overlay layers, inappropriate settings for container images
- Solutions: Apply nodatacow for container storage, tune for layer performance

### General System Sluggishness
- Symptoms: Slow file operations, poor random I/O performance
- Causes: Multiple factors including compression overhead, I/O scheduler issues
- Solutions: Comprehensive optimization of mount options and system parameters

## Tuning Recommendations Categories

### Mount Option Tuning
- Compression settings adjustments (zstd levels, compress=no for appropriate cases)
- I/O optimization flags (noatime, autodefrag, discard)
- Btrfs-specific options (space_cache, nodatacow)

### Layout Modifications
- Subvolume merging for workloads with compatible access patterns
- Subvolume splitting for I/O isolation
- Storage-tiering suggestions based on data importance/access patterns

### System-Level Tuning
- Kernel parameter adjustments related to I/O performance
- Block device queue depth and scheduler tuning
- Virtual memory settings for storage-heavy workloads

### Realistic Expectation Setting
- Performance projections based on hardware capabilities
- Acknowledgment of hardware limitations
- Timeframe estimates for implementing changes