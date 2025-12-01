## 1. Hardware Scanning with Facter (BLOCKER)

- [x] 1.1 Install facter from nixpkgs on target devices
- [x] 1.2 Run facter on zephyrus to collect hardware specs (CPU, RAM, storage, network, GPU, etc.)
- [x] 1.3 Run facter on yoga to collect hardware specs (CPU, RAM, storage, network, GPU, etc.)
- [x] 1.4 Generate /hosts/zephyrus/meta.nix from facter output
- [x] 1.5 Generate /hosts/yoga/meta.nix from facter output
- [x] 1.6 Verify hardware compatibility with NixOS using meta.nix data

## 2. Directory Structure Setup

- [x] 2.1 Create /hosts/zephyrus/ directory
- [x] 2.2 Create /hosts/yoga/ directory
- [x] 2.3 Ensure proper permissions and git tracking

## 3. Zephyrus Host Configuration

- [x] 3.1 Create /hosts/zephyrus/default.nix (basic host configuration)
- [x] 3.2 Create /hosts/zephyrus/hardware.nix (referencing meta.nix data)
- [x] 3.3 Create /hosts/zephyrus/disko.nix (disk partitioning based on meta.nix specs)
- [x] 3.4 Validate zephyrus configuration builds successfully

## 4. Yoga Host Configuration

- [x] 4.1 Create /hosts/yoga/default.nix (basic host configuration)
- [x] 4.2 Create /hosts/yoga/hardware.nix (referencing meta.nix data)
- [x] 4.3 Create /hosts/yoga/disko.nix (disk partitioning based on meta.nix specs)
- [x] 4.4 Validate yoga configuration builds successfully

## 5. Integration Testing

- [x] 5.1 Test both configurations build without errors
- [x] 5.2 Verify configurations are properly isolated
- [x] 5.3 Document any shared configuration patterns identified</content>
      <parameter name="filePath">openspec/changes/add-personal-device-hosts/tasks.md
