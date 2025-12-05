# lib/storage/hardware-profiles.nix
# Hardware Detection and Profile Selection Helpers

{ lib }:

let
  inherit (lib) attrByPath hasAttrByPath optional optionals elem concatStringsSep;
in

rec {
  # Task 2.1: Implement Zephyrus hardware detection
  # Detects dual-NVMe Zephyrus laptop
  # Returns true if both nvme0n1 and nvme1n1 present
  detectZephyrus = facterData:
    let
      disks = attrByPath [ "hardware" "disk" ] [ ] facterData;
      # Check if any disk has nvme0n1 or nvme1n1 in its unix_device_names
      checkDevice = deviceName: lib.any (d:
        lib.any (n: lib.hasInfix deviceName n) (d.unix_device_names or [])
      ) disks;
      hasNvme0n1 = checkDevice "nvme0n1";
      hasNvme1n1 = checkDevice "nvme1n1";
    in
    hasNvme0n1 && hasNvme1n1;

  # Task 2.2: Implement Yoga hardware detection
  # Detects single-NVMe Yoga laptop
  # Returns true if nvme0n1 present but nvme1n1 absent
  detectYoga = facterData:
    let
      disks = attrByPath [ "hardware" "disk" ] [ ] facterData;
      checkDevice = deviceName: lib.any (d:
        lib.any (n: lib.hasInfix deviceName n) (d.unix_device_names or [])
      ) disks;
      hasNvme0n1 = checkDevice "nvme0n1";
      hasNvme1n1 = checkDevice "nvme1n1";
    in
    hasNvme0n1 && !hasNvme1n1;

  # Task 2.3: Implement VPS hardware detection - Hetzner
  # Detects Hetzner VPS (~458GB)
  # Returns true for ~458GB virtio/scsi disk
  detectHetzner = facterData:
    let
      disks = attrByPath [ "hardware" "disk" ] [ ] facterData;
      hetznerDisk = lib.lists.findFirst (d:
        let
          driver = d.driver or "";
          size = lib.lists.findFirst (r: r.type == "size") null (d.resources or []);
          sizeBytes = if size != null then size.value_1 else 0;
          # Hetzner is approximately 458GB
          # Use production VPS size range (400GB-500GB)
          isHetznerSize = sizeBytes >= 450000000000 && sizeBytes <= 500000000000;
        in
        (lib.hasPrefix "virtio" driver || lib.hasPrefix "scsi" driver || driver == "virtio_scsi") && isHetznerSize
      ) null disks;
    in
    hetznerDisk != null;

  # Task 2.3: Implement VPS hardware detection - Contabo
  # Detects Contabo VPS (~536GB)
  # Returns true for ~536GB virtio/scsi disk
  detectContabo = facterData:
    let
      disks = attrByPath [ "hardware" "disk" ] [ ] facterData;
      contaboDisk = lib.lists.findFirst (d:
        let
          driver = d.driver or "";
          size = lib.lists.findFirst (r: r.type == "size") null (d.resources or []);
          sizeBytes = if size != null then size.value_1 else 0;
          # Contabo is approximately 536GB
          # Use production VPS size range (530GB-540GB)
          isContaboSize = sizeBytes >= 530000000000 && sizeBytes <= 540000000000;
        in
        (lib.hasPrefix "virtio" driver || lib.hasPrefix "scsi" driver || driver == "virtio_scsi") && isContaboSize
      ) null disks;
    in
    contaboDisk != null;

  # Task 2.3: Implement VPS hardware detection - OVH
  # Detects OVH VPS (~200GB)
  # Returns true for ~200GB virtio/scsi disk
  detectOVH = facterData:
    let
      disks = attrByPath [ "hardware" "disk" ] [ ] facterData;
      ovhDisk = lib.lists.findFirst (d:
        let
          driver = d.driver or "";
          size = lib.lists.findFirst (r: r.type == "size") null (d.resources or []);
          sizeBytes = if size != null then size.value_1 else 0;
          # OVH is approximately 200GB
          # Use production VPS size range (180GB-220GB)
          isOVHSize = sizeBytes >= 180000000000 && sizeBytes <= 220000000000;
        in
        (lib.hasPrefix "virtio" driver || lib.hasPrefix "scsi" driver || driver == "virtio_scsi") && isOVHSize
      ) null disks;
    in
    ovhDisk != null;

  # Task 2.4: Create profile selector function
  # Unified profile selector using hardware detection
  # Returns one of: "dev-laptop", "light-laptop", "production-vps", "staging-vps", "utility-vps", or "unknown"
  selectStorageProfile = facterData:
    if detectZephyrus facterData then
      "dev-laptop"
    else if detectYoga facterData then
      "light-laptop"
    else if detectHetzner facterData then
      "production-vps"
    else if detectContabo facterData then
      "staging-vps"
    else if detectOVH facterData then
      "utility-vps"
    else
      # Unknown hardware - warn and return unknown
      (builtins.trace "Warning: Unknown hardware configuration detected. Cannot determine storage profile." "unknown");
}
