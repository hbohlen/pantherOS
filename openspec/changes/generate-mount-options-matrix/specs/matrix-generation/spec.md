# Matrix Generation - Spec

## ADDED Requirements

### Requirement: Standardized Matrix Format
The system SHALL generate mount options matrices in a standardized table format with consistent columns for all subvolumes.

#### Scenario: Matrix Format Consistency
- **WHEN** generating mount options for any host configuration
- **THEN** the system produces a table with consistent columns: Subvolume, Mountpoint, Purpose, compress, noatime, autodefrag, nodatacow, discard, space_cache

#### Scenario: Column Completeness
- **WHEN** populating the matrix
- **THEN** every column is filled with either a recommended value or explicit "default" designation

### Requirement: Mount Option Recommendation System
The system SHALL recommend appropriate mount options based on subvolume purpose, host type, and workload profile.

#### Scenario: Purpose-Based Recommendations
- **WHEN** the subvolume purpose is identified as "database storage"
- **THEN** the system recommends nodatacow=true and compress=no for performance

#### Scenario: Host-Type Adaptive Options
- **WHEN** the host type is identified as "laptop"
- **THEN** the system considers battery life and mobility in option recommendations

#### Scenario: Workload-Profile Optimization
- **WHEN** the workload profile is "I/O intensive"
- **THEN** the system prioritizes performance-oriented mount options

### Requirement: Rationale Documentation
The system SHALL provide clear rationales explaining why each mount option value was recommended.

#### Scenario: Rationale for Compression Choice
- **WHEN** recommending a compression level for a subvolume
- **THEN** the system explains why that specific compression level was selected

#### Scenario: Safety vs Performance Trade-off Explanation
- **WHEN** making decisions that trade safety for performance or vice versa
- **THEN** the system documents the trade-offs considered in the decision