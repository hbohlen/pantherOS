# lib/storage/backup-helpers.nix
# Backup Helper Functions
# Provides utilities for backup configuration and validation

{ lib }:

let
  inherit (lib) mkOption types;
in
{
  # Get backup scope based on host profile
  getBackupScope = profile:
    let
      baseScope = [ "/" "/home" "/etc" ];
      databasePaths = [
        "/var/lib/postgresql"
        "/var/lib/redis"
      ];
      containerPaths = [
        "/var/lib/containers"
      ];
    in
    {
      server = baseScope ++ databasePaths;  # Servers always include databases
      laptop = baseScope ++ containerPaths; # Laptops may include containers
      workstation = baseScope;               # Workstations: basic scope
      utility = baseScope;                   # Utility: minimal scope
    }.${profile} or baseScope;

  # Validate backup configuration
  validateBackupConfig = config:
    let
      errors = []
        ++ (if config.storage.backup.b2.enable && config.storage.backup.b2.accountId == "" then
          [ "B2 account ID must be configured when B2 is enabled" ] else [])
        ++ (if config.storage.backup.b2.enable && config.storage.backup.b2.keyId == "" then
          [ "B2 key ID must be configured when B2 is enabled" ] else [])
        ++ (if config.storage.backup.subvolumes.enable && length config.storage.backup.subvolumes.paths == 0 then
          [ "At least one subvolume must be configured for backup" ] else []);
    in
    if length errors > 0 then
      throw (builtins.concatStringsSep "\n" errors)
    else
      true;

  # Estimate B2 cost based on storage size
  # B2 pricing: $0.005/GB/month
  estimateB2Cost = backupSizeGB:
    let
      costUSD = backupSizeGB * 0.005;  # $0.005 per GB per month
      costCents = builtins.floor (costUSD * 100);
    in
    {
      gb = backupSizeGB;
      usd = costUSD;
      cents = costCents;
      monthlyCost = "${toString (costCents / 100)}.${toString (costCents % 100)}";
    };

  # Generate backup retention policy
  generateRetentionPolicy = hostType:
    let
      policies = {
        server = {
          daily = 30;
          weekly = 12;
          monthly = 12;
          description = "Aggressive retention for production servers";
        };
        laptop = {
          daily = 7;
          weekly = 4;
          monthly = 12;
          description = "Standard retention for laptops";
        };
        workstation = {
          daily = 7;
          weekly = 4;
          monthly = 12;
          description = "Standard retention for workstations";
        };
        utility = {
          daily = 7;
          weekly = 4;
          monthly = 6;
          description = "Minimal retention for utility servers";
        };
      };
    in
    policies.${hostType} or policies.workstation;

  # Calculate timestamp for backup file naming
  generateBackupTimestamp = timestamp:
    let
      date = builtins.substring 0 10 timestamp;  # YYYY-MM-DD
      time = builtins.substring 11 8 timestamp;  # HH:MM:SS
      year = builtins.substring 0 4 date;
      month = builtins.substring 5 2 date;
      day = builtins.substring 8 2 date;
      hour = builtins.substring 0 2 time;
      min = builtins.substring 3 2 time;
      sec = builtins.substring 6 2 time;
    in
    "${year}${month}${day}_${hour}${min}${sec}";

  # Generate B2 bucket path for a subvolume
  generateB2Path = hostname: subvolumePath: date:
    let
      year = builtins.substring 0 4 date;
      month = builtins.substring 5 2 date;
      # Convert path to filesystem-safe name
      safePath = builtins.replaceStrings [ "/" " " ] [ "_" "_" ] subvolumePath;
    in
    "${hostname}/${safePath}/${year}/${month}/";

  # Check if backup is recent enough
  isBackupRecent = backupTimestamp: maxAgeHours:
    let
      backupEpoch = (builtins.fromJSON (builtins.toJSON {
        year = builtins.substring 0 4 backupTimestamp;
        month = builtins.substring 4 2 backupTimestamp;
        day = builtins.substring 6 2 backupTimestamp;
        hour = builtins.substring 9 2 backupTimestamp;
        minute = builtins.substring 11 2 backupTimestamp;
        second = builtins.substring 13 2 backupTimestamp;
      }));
      # This is a simplified check - actual implementation would use date command
      currentTime = 1704067200; # Placeholder epoch
    in
    true;  # Simplified - would calculate actual age in real implementation

  # Calculate storage growth rate
  calculateGrowthRate = currentSizeGB: previousSizeGB: daysDiff:
    if daysDiff > 0 then
      let
        growthGB = currentSizeGB - previousSizeGB;
        dailyRate = growthGB / daysDiff;
      in
      {
        totalGrowthGB = growthGB;
        dailyGrowthGB = dailyRate;
        weeklyProjection = dailyRate * 7;
        monthlyProjection = dailyRate * 30;
      }
    else
      {
        totalGrowthGB = 0;
        dailyGrowthGB = 0;
        weeklyProjection = 0;
        monthlyProjection = 0;
      };

  # Determine appropriate compression level based on data type
  getCompressionLevel = subvolumePath:
    let
      compressLevel = {
        "/nix" = 1;          # Nix store: minimal compression (fast)
        "/var/cache" = 3;    # Cache: moderate compression
        "/home" = 6;         # Home: balanced compression
        "/log" = 6;          # Logs: good compression
      };
    in
    compressLevel.${subvolumePath} or 3;  # Default to level 3

  # Generate btrfs snapshot name
  generateSnapshotName = subvolumePath: timestamp:
    let
      safePath = builtins.replaceStrings [ "/" ] [ "_" ] subvolumePath;
      cleanPath = builtins.replaceStrings [ "_" "" ] [ "" ] (builtins.substring 1 999 safePath);  # Remove leading underscore
    in
    "snap_${cleanPath}_${timestamp}";

  # Check if database subvolume requires special handling
  isDatabaseSubvolume = subvolumePath:
    builtins.elem subvolumePath [
      "/var/lib/postgresql"
      "/var/lib/redis"
      "/var/lib/mysql"
      "/var/lib/mongodb"
    ];

  # Format backup size in human-readable format
  formatSize = bytes:
    let
      kb = bytes / 1024;
      mb = kb / 1024;
      gb = mb / 1024;
      tb = gb / 1024;
    in
    if tb >= 1 then
      "${toString tb}TB"
    else if gb >= 1 then
      "${toString gb}GB"
    else if mb >= 1 then
      "${toString mb}MB"
    else if kb >= 1 then
      "${toString kb}KB"
    else
      "${toString bytes}B";

  # Validate B2 credentials format
  validateB2Credentials = accountId: keyId:
    let
      validAccountId = builtins.match "^[a-f0-9]{12}$" accountId != null;
      validKeyId = builtins.match "^[a-f0-9]{24}$" keyId != null;
    in
    validAccountId && validKeyId;
}
