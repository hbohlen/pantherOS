# meta.nix - Zephyrus hardware specifications
# TODO: This is a placeholder - replace with actual facter report data
# Run: nix run nixpkgs#nixos-facter -- -o hardware-reports/zephyrus-$(date +%Y%m%d-%H%M%S).json
# Then generate this file from the JSON output

{
  # Basic system information
  hostname = "zephyrus";
  system = "x86_64-linux";
  virtualization = "none";

  # CPU specifications - placeholder
  cpu = {
    vendor = "TODO";  # e.g., "AuthenticAMD" or "GenuineIntel"
    model = "TODO";   # Update with actual CPU model
    cores = 0;        # Update with actual core count
    threads = 0;      # Update with actual thread count
    architecture = "x86_64";
    features = [ ];   # Update with actual CPU features
  };

  # Memory specifications - placeholder
  memory = {
    total = "TODO";   # e.g., "16GB"
    type = "TODO";    # e.g., "DDR5"
  };

  # Storage - placeholder
  storage = {
    count = 0;        # Update with actual disk count
  };

  # Network - placeholder
  network = {
    interfaces = 0;   # Update with actual interface count
  };

  # Graphics - placeholder
  graphics = {
    integrated = "TODO";  # Update with actual GPU
  };

  # Additional hardware - placeholder
  bluetooth = false;  # Update based on hardware
  camera = false;     # Update based on hardware
  sound = false;      # Update based on hardware

  # Hardware report timestamp - placeholder
  reportDate = "TODO";
  reportPath = ../../hardware-reports/zephyrus-TODO.json;
}