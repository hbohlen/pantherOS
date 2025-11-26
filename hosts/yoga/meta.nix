# hosts/yoga/meta.nix
# Hardware specifications for Yoga device
# Generated from nixos-facter report: hardware-reports/yoga-20251126-152255.json

{
  # Basic system information
  hostname = "yoga";
  system = "x86_64-linux";
  virtualization = "none";

  # CPU specifications
  cpu = {
    vendor = "AuthenticAMD";
    model = "AMD Ryzen AI 7 350 w/ Radeon 860M";
    cores = 8;
    threads = 16;
    architecture = "x86_64";
    features = [
      "avx512f" "avx512dq" "avx512ifma" "avx512cd" "avx512bw" "avx512vl"
      "avx2" "avx" "sse4_2" "sse4_1" "ssse3" "sse2" "aes" "pclmulqdq"
      "fma" "movbe" "popcnt" "xsave" "avx512_bf16" "avx_vnni" "sha_ni"
    ];
  };

  # Memory specifications
  memory = {
    total = "16GB";  # 16106127360 bytes
    type = "DDR5";   # Based on typical Ryzen AI configurations
  };

  # Storage - detected 2 disks
  storage = {
    count = 2;
    # Specific disk details would be configured in disko.nix
  };

  # Network - detected 2 interfaces
  network = {
    interfaces = 2;
    # Wireless and Ethernet interfaces detected
  };

  # Graphics
  graphics = {
    integrated = "Radeon 860M";  # Integrated in Ryzen AI 350
  };

  # Additional detected hardware
  bluetooth = true;
  camera = true;
  sound = true;

  # Hardware report timestamp
  reportDate = "2025-11-26T15:22:55Z";
  reportPath = ../../hardware-reports/yoga-20251126-152255.json;
}