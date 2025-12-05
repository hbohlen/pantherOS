{ pkgs, nix-unit }:

let
  inherit (pkgs) lib;

  # Import laptop-disk module configuration
  laptopDiskConfig = {
    storage.disks.laptop = {
      enable = true;
      device = "/dev/nvme0n1";
      enableDatabases = true;
    };
  };

  # Import server-disk module configuration
  serverDiskConfig = {
    storage.disks.server = {
      enable = true;
      device = "/dev/vda";
      size = "458GB";
      enableDatabases = true;
      enableContainers = true;
    };
  };

  # Helper to check if subvolume exists in disko config
  hasSubvolume = subvolName: config:
    lib.hasAttr [ "disko" "devices" "disk" ] config
    && lib.any (device:
      lib.hasAttr [ "content" "partitions" "root" "content" "subvolumes" subvolName ] device
    ) (lib.attrValues config.disko.devices.disk);

  # Helper to get mount options for a subvolume
  getMountOptions = subvolName: config:
    let
      devices = lib.attrValues config.disko.devices.disk;
      findSubvol = lib.lists.findFirst (device:
        lib.hasAttr [ "content" "partitions" "root" "content" "subvolumes" subvolName ] device
      ) null devices;
    in
    if findSubvol == null then []
    else findSubvol.content.partitions.root.content.subvolumes.${subvolName}.mountOptions or [];

  # Helper to check if nodatacow is present
  hasNodatacow = options: lib.elem "nodatacow" options;

  # Helper to check if compression is set
  hasCompression = options:
    lib.any (opt: lib.hasPrefix "compress=" opt) options;

  # Helper to get compression level
  getCompressionLevel = options:
    let
      compressOpts = lib.filter (opt: lib.hasPrefix "compress=" opt) options;
    in
    if compressOpts == [] then null
    else lib.head compressOpts;

in

{
  test_laptop_has_root_subvolume = {
    name = "Laptop profile has root subvolume (@)";
    testScript = ''
      let
        lib = pkgs.lib;
        laptopDiskConfig = {
          storage.disks.laptop = {
            enable = true;
            device = "/dev/nvme0n1";
            enableDatabases = true;
          };
        };
        config = laptopDiskConfig;
        hasRoot = lib.hasAttr [ "disko" "devices" "disk" ] config
          && lib.any (device:
            lib.hasAttr [ "content" "partitions" "root" "content" "subvolumes" "@" ] device
          ) (lib.attrValues config.disko.devices.disk);
      in
      assert hasRoot == true
    '';
  };

  test_laptop_has_home_subvolume = {
    name = "Laptop profile has home subvolume (@home)";
    testScript = ''
      let
        lib = pkgs.lib;
        laptopDiskConfig = {
          storage.disks.laptop = {
            enable = true;
            device = "/dev/nvme0n1";
            enableDatabases = true;
          };
        };
        config = laptopDiskConfig;
        hasHome = lib.hasAttr [ "disko" "devices" "disk" ] config
          && lib.any (device:
            lib.hasAttr [ "content" "partitions" "root" "content" "subvolumes" "@home" ] device
          ) (lib.attrValues config.disko.devices.disk);
      in
      assert hasHome == true
    '';
  };

  test_laptop_has_nix_subvolume = {
    name = "Laptop profile has nix subvolume (@nix)";
    testScript = ''
      let
        lib = pkgs.lib;
        laptopDiskConfig = {
          storage.disks.laptop = {
            enable = true;
            device = "/dev/nvme0n1";
            enableDatabases = true;
          };
        };
        config = laptopDiskConfig;
        hasNix = lib.hasAttr [ "disko" "devices" "disk" ] config
          && lib.any (device:
            lib.hasAttr [ "content" "partitions" "root" "content" "subvolumes" "@nix" ] device
          ) (lib.attrValues config.disko.devices.disk);
      in
      assert hasNix == true
    '';
  };

  test_server_has_database_when_enabled = {
    name = "Server profile has database subvolumes when enabled";
    testScript = ''
      let
        lib = pkgs.lib;
        serverDiskConfig = {
          storage.disks.server = {
            enable = true;
            device = "/dev/vda";
            size = "458GB";
            enableDatabases = true;
            enableContainers = true;
          };
        };
        config = serverDiskConfig;
        hasPostgres = lib.hasAttr [ "disko" "devices" "disk" ] config
          && lib.any (device:
            lib.hasAttr [ "content" "partitions" "root" "content" "subvolumes" "@postgresql" ] device
          ) (lib.attrValues config.disko.devices.disk);
      in
      assert hasPostgres == true
    '';
  };

  test_database_subvolumes_have_nodatacow = {
    name = "Database subvolumes have nodatacow";
    testScript = ''
      let
        lib = pkgs.lib;
        serverDiskConfig = {
          storage.disks.server = {
            enable = true;
            device = "/dev/vda";
            size = "458GB";
            enableDatabases = true;
            enableContainers = true;
          };
        };
        config = serverDiskConfig;
        devices = lib.attrValues config.disko.devices.disk;
        findSubvol = lib.lists.findFirst (device:
          lib.hasAttr [ "content" "partitions" "root" "content" "subvolumes" "@postgresql" ] device
        ) null devices;
        postgresOptions = if findSubvol == null then [] else findSubvol.content.partitions.root.content.subvolumes."@postgresql".mountOptions or [];
        hasNodatacow = lib.elem "nodatacow" postgresOptions;
      in
      assert hasNodatacow == true
    '';
  };

  test_redis_has_nodatacow = {
    name = "Redis subvolume has nodatacow";
    testScript = ''
      let
        lib = pkgs.lib;
        serverDiskConfig = {
          storage.disks.server = {
            enable = true;
            device = "/dev/vda";
            size = "458GB";
            enableDatabases = true;
            enableContainers = true;
          };
        };
        config = serverDiskConfig;
        devices = lib.attrValues config.disko.devices.disk;
        findSubvol = lib.lists.findFirst (device:
          lib.hasAttr [ "content" "partitions" "root" "content" "subvolumes" "@redis" ] device
        ) null devices;
        redisOptions = if findSubvol == null then [] else findSubvol.content.partitions.root.content.subvolumes."@redis".mountOptions or [];
        hasNodatacow = lib.elem "nodatacow" redisOptions;
      in
      assert hasNodatacow == true
    '';
  };

  test_containers_have_nodatacow = {
    name = "Container subvolume has nodatacow";
    testScript = ''
      let
        lib = pkgs.lib;
        laptopDiskConfig = {
          storage.disks.laptop = {
            enable = true;
            device = "/dev/nvme0n1";
            enableDatabases = true;
          };
        };
        config = laptopDiskConfig;
        devices = lib.attrValues config.disko.devices.disk;
        findSubvol = lib.lists.findFirst (device:
          lib.hasAttr [ "content" "partitions" "root" "content" "subvolumes" "@containers" ] device
        ) null devices;
        containersOptions = if findSubvol == null then [] else findSubvol.content.partitions.root.content.subvolumes."@containers".mountOptions or [];
        hasNodatacow = lib.elem "nodatacow" containersOptions;
      in
      assert hasNodatacow == true
    '';
  };

  test_root_has_compression = {
    name = "Root subvolume has compression enabled";
    testScript = ''
      let
        lib = pkgs.lib;
        laptopDiskConfig = {
          storage.disks.laptop = {
            enable = true;
            device = "/dev/nvme0n1";
            enableDatabases = true;
          };
        };
        config = laptopDiskConfig;
        devices = lib.attrValues config.disko.devices.disk;
        findSubvol = lib.lists.findFirst (device:
          lib.hasAttr [ "content" "partitions" "root" "content" "subvolumes" "@" ] device
        ) null devices;
        rootOptions = if findSubvol == null then [] else findSubvol.content.partitions.root.content.subvolumes."@".mountOptions or [];
        compressOpts = lib.filter (opt: lib.hasPrefix "compress=" opt) rootOptions;
      in
      assert compressOpts != []
    '';
  };
}
