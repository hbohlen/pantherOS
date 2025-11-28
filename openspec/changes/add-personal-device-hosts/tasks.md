## 1. Hardware Scanning with Facter (BLOCKER)

- [ ] 1.1 Install facter from nixpkgs on target devices
- [ ] 1.2 Run facter on zephyrus to collect hardware specs (CPU, RAM, storage, network, GPU, etc.)
- [ ] 1.3 Run facter on yoga to collect hardware specs (CPU, RAM, storage, network, GPU, etc.)
- [ ] 1.4 Generate /hosts/zephyrus/meta.nix from facter output
- [ ] 1.5 Generate /hosts/yoga/meta.nix from facter output
- [ ] 1.6 Verify hardware compatibility with NixOS using meta.nix data

## 2. Directory Structure Setup

- [ ] 2.1 Create /hosts/zephyrus/ directory
- [ ] 2.2 Create /hosts/yoga/ directory
- [ ] 2.3 Ensure proper permissions and git tracking

## 3. Zephyrus Host Configuration

- [ ] 3.1 Create /hosts/zephyrus/default.nix (basic host configuration)
- [ ] 3.2 Create /hosts/zephyrus/hardware.nix (referencing meta.nix data)
- [ ] 3.3 Create /hosts/zephyrus/disko.nix (disk partitioning based on meta.nix specs)
- [ ] 3.4 Validate zephyrus configuration builds successfully

## 4. Yoga Host Configuration

- [ ] 4.1 Create /hosts/yoga/default.nix (basic host configuration)
- [ ] 4.2 Create /hosts/yoga/hardware.nix (referencing meta.nix data)
- [ ] 4.3 Create /hosts/yoga/disko.nix (disk partitioning based on meta.nix specs)
- [ ] 4.4 Validate yoga configuration builds successfully

## 5. Integration Testing

- [ ] 5.1 Test both configurations build without errors
- [ ] 5.2 Verify configurations are properly isolated
- [ ] 5.3 Document any shared configuration patterns identified</content>
      <parameter name="filePath">openspec/changes/add-personal-device-hosts/tasks.md
