# Analyze Asus ROG Zephyrus Hardware and Generate Optimized Subvolume Layout - Tasks

## Implementation Tasks

1. **Hardware Profile Analysis**
   - Parse and analyze the facter.json file for the Zephyrus laptop
   - Identify device names (nvme0n1, nvme1n1) and their characteristics
   - Determine which disk is Crucial P3 2TB and which is Micron 2450 1TB
   - Extract NVMe controller details and capabilities

2. **Development Workload I/O Analysis**
   - Analyze I/O patterns for Zed IDE and its cache/project directories
   - Examine Podman container and volume patterns
   - Evaluate browser cache patterns (Vivaldi)
   - Assess Git repository behavior in ~/dev

3. **Drive Characteristic Comparison**
   - Compare performance characteristics of Crucial P3 vs Micron 2450
   - Determine optimal placement based on workload requirements
   - Consider endurance and performance differences between drives

4. **Generate Multi-Disk Subvolume Layout**
   - Design subvolume layout optimized for development speed
   - Plan placement of system components on appropriate drives
   - Create ASCII diagram of the recommended layout

5. **Mount Options Matrix Creation**
   - Develop mount options table for key subvolumes
   - Consider compression settings for different data types
   - Apply appropriate performance vs safety options

6. **Snapshot and Backup Strategy Design**
   - Create snapshot strategy specific to development laptop
   - Design backup procedures for code and project data
   - Plan retention policies for different data criticality

7. **Validation and Testing**
   - Validate the proposed layout against best practices
   - Test the strategy with simulated development workloads
   - Ensure all mount options are valid for btrfs

8. **Documentation**
   - Document the rationale behind drive split decisions
   - Create detailed explanation of the layout choices
   - Provide migration guidelines from existing configurations