# Recommendation and Estimation - Spec

## ADDED Requirements

### Requirement: Per-Subvolume Compression Recommendations
The system SHALL provide individualized compression recommendations for each subvolume based on its specific data type and hosting requirements.

#### Scenario: Development Subvolume Recommendation
- **WHEN** the subvolume contains development files (source code, configs, build artifacts)
- **THEN** the system recommends high compression (zstd:3) for excellent space savings

#### Scenario: Container Storage Recommendation
- **WHEN** the subvolume stores container images and data
- **THEN** the system recommends no compression (compress=no) to avoid double compression

### Requirement: Effective Capacity Gain Estimation
The system SHALL calculate and report the expected effective capacity gain from the selected compression strategy.

#### Scenario: Capacity Gain Calculation
- **WHEN** applying compression recommendations to a set of subvolumes
- **THEN** the system estimates the total effective capacity gain from the compression strategy

#### Scenario: Compression Ratio Projections
- **WHEN** recommending compression for a specific data type
- **THEN** the system provides estimated compression ratios based on data type characteristics

### Requirement: Reason and Justification Provision
The system SHALL provide clear reasons for each compression recommendation to aid in understanding and validation.

#### Scenario: Recommendation Rationale
- **WHEN** recommending a specific compression level for a subvolume
- **THEN** the system provides clear rationale explaining why that level was selected

#### Scenario: Trade-off Analysis
- **WHEN** making compression recommendations that involve trade-offs
- **THEN** the system documents the performance vs space trade-offs considered