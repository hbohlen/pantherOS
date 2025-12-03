# Compression Analysis - Spec

## ADDED Requirements

### Requirement: CPU vs Compression Trade-off Analysis
The system SHALL provide comprehensive analysis of CPU cost vs compression benefit for different zstd levels (zstd:1, zstd:3, zstd:6).

#### Scenario: CPU Overhead Assessment
- **WHEN** evaluating compression options for a subvolume
- **THEN** the system analyzes expected CPU overhead for each compression level

#### Scenario: Hardware-Adaptive Compression Selection
- **WHEN** system has limited CPU resources
- **THEN** the system prioritizes lower-compression options to reduce CPU overhead

### Requirement: Data Type-Specific Compression Recommendations
The system SHALL recommend different compression levels based on the specific data types present in each subvolume.

#### Scenario: Text-Heavy Data Compression
- **WHEN** the subvolume contains source code, configs, or log files
- **THEN** the system recommends high compression (e.g., zstd:3) due to excellent compression ratios

#### Scenario: Binary/Already-Compressed Data
- **WHEN** the subvolume contains media files, pre-compressed archives, or container images
- **THEN** the system recommends low compression or no compression (compress=no) to avoid wasted CPU cycles

### Requirement: Explicit Compression Disable Guidance
The system SHALL explicitly recommend when compression should be disabled entirely.

#### Scenario: Database File Handling
- **WHEN** the subvolume stores database files
- **THEN** the system recommends whether to use compression or disable it based on database type and performance requirements

#### Scenario: Performance-Critical Storage
- **WHEN** the subvolume serves performance-critical applications
- **THEN** the system evaluates whether compression overhead justifies the space savings