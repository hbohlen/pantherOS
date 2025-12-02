# Spec: Storage Optimization

## ADDED Requirements

### NVMe Performance Tuning
The system must be optimized for NVMe SSD performance and longevity.

#### Scenario: TRIM Support
Given the system uses NVMe SSDs
When the system is running
Then periodic TRIM operations should be scheduled (fstrim.timer)

#### Scenario: Swappiness
Given the system has ample RAM (Zephyrus)
When configuring kernel parameters
Then `vm.swappiness` should be set to 10 to prefer RAM over swap
