# Compare Hosts via Facter - Tasks

## Implementation Tasks

1. **Research and Analysis**
   - Study existing facter.json structures and formats from yoga and zephyrus hosts
   - Understand current disko.nix configuration patterns in the pantherOS project
   - Review hardware comparison methodologies and btrfs best practices for different storage types
   - Analyze existing hardware-detection.nix utilities for potential reuse

2. **Design Implementation**
   - Define comparison algorithm between hardware profiles with focus on storage characteristics
   - Design host-specific disko.nix strategy generation with modular components
   - Plan storage optimization strategies based on hardware differences (NVMe vs SSD vs HDD)
   - Create interface specifications for each component in the architecture

3. **Build Hardware Profiler Module**
   - Create a Nix module to extract CPU information (architecture, cores, performance) from facter.json
   - Create a Nix module to extract RAM information (size, speed, configuration) from facter.json
   - Create a Nix module to extract and categorize storage devices (type, capacity, performance) from facter.json
   - Create a Nix module to identify virtualization capabilities and form factor from facter.json

4. **Build Hardware Comparison Engine**
   - Create a comparison function that analyzes two facter.json files and identifies meaningful differences
   - Implement hardware difference detection algorithms for CPU, RAM, storage, and virtualization
   - Generate structured comparison reports highlighting differences that impact storage strategy
   - Add validation to ensure facter.json files are properly formatted and contain necessary information

5. **Build Workload Profile Analyzer**
   - Create interface for specifying workload profiles (dev vs prod, containers vs DB vs general use)
   - Implement workload categorization algorithms
   - Map workload types to storage requirements and constraints
   - Develop profiling parameters for I/O patterns and reliability needs

6. **Build Disko Strategy Generator**
   - Develop btrfs subvolume layout generation logic based on hardware and workload profiles
   - Create mount options matrix for different subvolume purposes and storage types
   - Implement snapshot and backup strategy determination algorithms
   - Generate disko.nix configurations with appropriate abstractions and safety checks

7. **Create Strategy Validation Module**
   - Implement validation for generated disko configurations against hardware constraints
   - Add checks for configuration conflicts or impossible setups
   - Provide feedback and suggestions for configuration improvements
   - Create verification tests for generated configurations

8. **Integration and Testing**
   - Create test cases using yoga and zephyrus facter.json files with different workload profiles
   - Verify generated disko.nix configurations work correctly with disko and nix
   - Test that configurations are properly optimized for each host's hardware profile
   - Validate that different hardware configurations result in meaningfully different disko strategies

9. **Documentation and Examples**
   - Document module interfaces and usage patterns
   - Create example configurations showing different hardware scenarios
   - Document the decision-making process for each configuration choice
   - Provide a guide for users on how to specify workload profiles