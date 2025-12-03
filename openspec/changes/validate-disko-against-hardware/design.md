# Validate Proposed Disko.nix Against Best Practices and Hardware Reality - Design

## Architectural Overview

The system will implement a disko.nix validation framework that systematically checks proposed configurations against hardware reality and best practices. The architecture includes modules for hardware analysis, configuration parsing, validation checks, and comprehensive reporting.

## Components

### 1. Hardware Analyzer
- Parses facter.json to extract device information (disks, partitions, etc.)
- Identifies available storage devices and their characteristics
- Extracts system properties relevant to storage configuration
- Provides hardware profile for validation checks

### 2. Configuration Parser
- Parses the proposed disko.nix configuration
- Extracts disk layout, partitioning, and subvolume information
- Identifies mount options and filesystem settings
- Creates internal representation for validation

### 3. Hardware Compatibility Validator
- Checks device paths in disko.nix against actual hardware in facter.json
- Validates partition schemes against storage device capabilities
- Ensures proposed storage configuration is physically possible
- Identifies missing or non-existent devices

### 4. Layout Sanity Checker
- Analyzes subvolume layout for missing essential subvolumes
- Identifies over-fragmentation into excessive subvolumes
- Checks for appropriate grouping of related data
- Validates separation of different data types

### 5. Mount Options Validator
- Checks for conflicting or problematic mount option combinations
- Validates use of safe defaults where appropriate
- Identifies potentially risky mount options
- Ensures mount options are appropriate for data types

### 6. Backup/Snapshot Implications Analyzer
- Assesses snapshot-friendliness of the layout
- Identifies high-risk areas for backup/restore operations
- Evaluates subvolume grouping for backup efficiency
- Considers snapshot retention and space implications

### 7. Issue Aggregator
- Collects all identified issues and risks
- Categorizes issues by severity and type
- Prioritizes issues for reporting

### 8. Recommendation Engine
- Generates concrete fix suggestions for identified issues
- Creates diff-style recommendations where applicable
- Produces cleaned-up configuration alternatives
- Provides implementation guidance

## Data Flow

1. Input: facter.json, proposed disko.nix, host role description
2. Hardware Analysis: Extract device information from facter.json
3. Configuration Parsing: Parse disko.nix configuration structure
4. Validation Pipeline: Run through all validation modules
5. Issue Aggregation: Collect and categorize all issues
6. Recommendation Generation: Create fix suggestions
7. Output: Generate issue list, recommendations, and go/no-go summary

## Key Algorithms

### Hardware Device Matching
- Compare device paths in disko.nix (/dev/sda, /dev/nvme0n1) with those in facter.json
- Validate that proposed partition sizes fit within actual device capacities
- Check interface compatibility (SSD vs HDD considerations)

### Subvolume Layout Analysis
- Identify essential subvolumes that should typically exist (@root, @home, @nix)
- Flag excessive fragmentation that could impact management
- Validate logical grouping of related data types
- Check for appropriate separation of system and user data

### Mount Option Safety Checking
- Identify conflicting mount options (e.g., nodatacow + compression)
- Validate option combinations for known issues
- Check for deprecated or experimental options
- Ensure options match data type requirements

## Technology Stack

- Nix/NixOS for configuration validation and domain-specific language
- Standard Nixpkgs libraries for data processing and validation utilities
- Existing hardware detection utilities for facter.json analysis
- Standard NixOS modules for disko.nix validation
- Nix expression language for validation logic

## Implementation Patterns

### Comprehensive Validation
- Check all aspects of the configuration systematically
- Validate against best practices and common patterns
- Consider both immediate and long-term implications

### Actionable Reporting
- Provide specific, implementable fix suggestions
- Include context and reasoning for each recommendation
- Offer alternatives where multiple solutions exist

### Risk-Based Assessment
- Categorize issues by severity (critical, warning, informational)
- Prioritize fixes by potential impact
- Provide risk assessment for deployment decisions

## Validation Categories

### Hardware Compatibility Checks
- Device path existence and matching
- Partition size vs disk capacity verification
- Filesystem type compatibility with hardware
- Interface-specific optimizations

### Layout Sanity Checks
- Essential subvolume presence
- Appropriate subvolume granularities
- Logical data grouping and separation
- Scalability considerations

### Mount Options Validation
- Conflicting option detection
- Safety and performance option validation
- Data type appropriateness
- Performance impact assessment

### Backup/Snapshot Implications
- Snapshot operation efficiency
- Recovery scenario analysis
- Space usage considerations
- High-risk area identification

## Output Specifications

### Issue Classification
- Critical: Issues that will likely cause deployment failure
- Warning: Issues that may cause performance or reliability problems
- Informational: Suggestions for improvement or best practices

### Recommendation Format
- Clear description of the issue and its impact
- Specific, implementable fix suggestions
- Diff-style changes where applicable
- Rationale for the recommendation

### Go/No-Go Assessment
- Risk level summary based on identified issues
- Readiness assessment for deployment
- Priority fixes required before deployment