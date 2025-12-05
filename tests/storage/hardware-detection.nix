{ pkgs, nix-unit }:

let
  inherit (pkgs) lib;
  storageLib = import ../../lib/storage { inherit lib; };

  # Zephyrus dual-NVMe test data (minimal disk section)
  zephyrusFacterData = {
    hardware.disk = [
      {
        unix_device_names = [ "/dev/disk/by-id/nvme-CT2000P310SSD8_24514D0F486C" "/dev/nvme0n1" ];
        sysfs_id = "/class/block/nvme0n1";
      }
      {
        unix_device_names = [ "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_xxx" "/dev/nvme1n1" ];
        sysfs_id = "/class/block/nvme1n1";
      }
    ];
  };

  # Yoga single-NVMe test data (minimal disk section)
  yogaFacterData = {
    hardware.disk = [
      {
        unix_device_names = [ "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_xxx" "/dev/nvme0n1" ];
        sysfs_id = "/class/block/nvme0n1";
      }
    ];
  };

  # Hetzner VPS test data (~458GB virtio disk)
  hetznerFacterData = {
    hardware.disk = [
      {
        driver = "virtio_scsi";
        unix_device_names = [ "/dev/vda" ];
        sysfs_id = "/class/block/vda";
        resources = [
          {
            type = "size";
            value_1 = 458900000000; # ~458GB
          }
        ];
      }
    ];
  };

  # Contabo VPS test data (~536GB virtio disk)
  contaboFacterData = {
    hardware.disk = [
      {
        driver = "virtio_scsi";
        unix_device_names = [ "/dev/vda" ];
        sysfs_id = "/class/block/vda";
        resources = [
          {
            type = "size";
            value_1 = 536800000000; # ~536GB
          }
        ];
      }
    ];
  };

  # OVH VPS test data (~200GB virtio disk)
  ovhFacterData = {
    hardware.disk = [
      {
        driver = "virtio_scsi";
        unix_device_names = [ "/dev/vda" ];
        sysfs_id = "/class/block/vda";
        resources = [
          {
            type = "size";
            value_1 = 204800000000; # ~200GB
          }
        ];
      }
    ];
  };

  # Unknown hardware test data
  unknownFacterData = {
    hardware.disk = [
      {
        driver = "unknown_driver";
        unix_device_names = [ "/dev/sda" ];
        sysfs_id = "/class/block/sda";
        resources = [
          {
            type = "size";
            value_1 = 100000000000; # ~100GB
          }
        ];
      }
    ];
  };

in

{
  test_zephyrus_detection = {
    name = "Zephyrus hardware detection";
    testScript = ''
      let
        lib = pkgs.lib;
        storageLib = import ../../lib/storage { inherit lib; };
        zephyrusFacterData = {
          hardware.disk = [
            {
              unix_device_names = [ "/dev/disk/by-id/nvme-CT2000P310SSD8_24514D0F486C" "/dev/nvme0n1" ];
              sysfs_id = "/class/block/nvme0n1";
            }
            {
              unix_device_names = [ "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_xxx" "/dev/nvme1n1" ];
              sysfs_id = "/class/block/nvme1n1";
            }
          ];
        };
        hardwareProfiles = storageLib;
        facterData = zephyrusFacterData;
        result = hardwareProfiles.selectStorageProfile facterData;
      in
      assert result == "dev-laptop"
    '';
  };

  test_yoga_detection = {
    name = "Yoga hardware detection";
    testScript = ''
      let
        lib = pkgs.lib;
        storageLib = import ../../lib/storage { inherit lib; };
        yogaFacterData = {
          hardware.disk = [
            {
              unix_device_names = [ "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_xxx" "/dev/nvme0n1" ];
              sysfs_id = "/class/block/nvme0n1";
            }
          ];
        };
        hardwareProfiles = storageLib;
        facterData = yogaFacterData;
        result = hardwareProfiles.selectStorageProfile facterData;
      in
      assert result == "light-laptop"
    '';
  };

  test_hetzner_detection = {
    name = "Hetzner VPS detection";
    testScript = ''
      let
        lib = pkgs.lib;
        storageLib = import ../../lib/storage { inherit lib; };
        hetznerFacterData = {
          hardware.disk = [
            {
              driver = "virtio_scsi";
              unix_device_names = [ "/dev/vda" ];
              sysfs_id = "/class/block/vda";
              resources = [
                {
                  type = "size";
                  value_1 = 458900000000; # ~458GB
                }
              ];
            }
          ];
        };
        hardwareProfiles = storageLib;
        facterData = hetznerFacterData;
        result = hardwareProfiles.selectStorageProfile facterData;
      in
      assert result == "production-vps"
    '';
  };

  test_contabo_detection = {
    name = "Contabo VPS detection";
    testScript = ''
      let
        lib = pkgs.lib;
        storageLib = import ../../lib/storage { inherit lib; };
        contaboFacterData = {
          hardware.disk = [
            {
              driver = "virtio_scsi";
              unix_device_names = [ "/dev/vda" ];
              sysfs_id = "/class/block/vda";
              resources = [
                {
                  type = "size";
                  value_1 = 536800000000; # ~536GB
                }
              ];
            }
          ];
        };
        hardwareProfiles = storageLib;
        facterData = contaboFacterData;
        result = hardwareProfiles.selectStorageProfile facterData;
      in
      assert result == "staging-vps"
    '';
  };

  test_ovh_detection = {
    name = "OVH VPS detection";
    testScript = ''
      let
        lib = pkgs.lib;
        storageLib = import ../../lib/storage { inherit lib; };
        ovhFacterData = {
          hardware.disk = [
            {
              driver = "virtio_scsi";
              unix_device_names = [ "/dev/vda" ];
              sysfs_id = "/class/block/vda";
              resources = [
                {
                  type = "size";
                  value_1 = 204800000000; # ~200GB
                }
              ];
            }
          ];
        };
        hardwareProfiles = storageLib;
        facterData = ovhFacterData;
        result = hardwareProfiles.selectStorageProfile facterData;
      in
      assert result == "utility-vps"
    '';
  };

  test_unknown_hardware = {
    name = "Unknown hardware returns unknown profile";
    testScript = ''
      let
        lib = pkgs.lib;
        storageLib = import ../../lib/storage { inherit lib; };
        unknownFacterData = {
          hardware.disk = [
            {
              driver = "unknown_driver";
              unix_device_names = [ "/dev/sda" ];
              sysfs_id = "/class/block/sda";
              resources = [
                {
                  type = "size";
                  value_1 = 100000000000; # ~100GB
                }
              ];
            }
          ];
        };
        hardwareProfiles = storageLib;
        facterData = unknownFacterData;
        result = hardwareProfiles.selectStorageProfile facterData;
      in
      assert result == "unknown"
    '';
  };

  test_zephyrus_detect_zephyrus = {
    name = "Zephyrus detection function";
    testScript = ''
      let
        lib = pkgs.lib;
        storageLib = import ../../lib/storage { inherit lib; };
        zephyrusFacterData = {
          hardware.disk = [
            {
              unix_device_names = [ "/dev/disk/by-id/nvme-CT2000P310SSD8_24514D0F486C" "/dev/nvme0n1" ];
              sysfs_id = "/class/block/nvme0n1";
            }
            {
              unix_device_names = [ "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_xxx" "/dev/nvme1n1" ];
              sysfs_id = "/class/block/nvme1n1";
            }
          ];
        };
        hardwareProfiles = storageLib;
        facterData = zephyrusFacterData;
        result = hardwareProfiles.detectZephyrus facterData;
      in
      assert result == true
    '';
  };

  test_yoga_not_zephyrus = {
    name = "Yoga is not Zephyrus";
    testScript = ''
      let
        lib = pkgs.lib;
        storageLib = import ../../lib/storage { inherit lib; };
        yogaFacterData = {
          hardware.disk = [
            {
              unix_device_names = [ "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_xxx" "/dev/nvme0n1" ];
              sysfs_id = "/class/block/nvme0n1";
            }
          ];
        };
        hardwareProfiles = storageLib;
        facterData = yogaFacterData;
        result = hardwareProfiles.detectZephyrus facterData;
      in
      assert result == false
    '';
  };
}
