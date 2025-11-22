{ config, lib, ... }:

with lib;

let
  cfg = config.pantherOS.security.kernel;
in
{
  options.pantherOS.security.kernel = {
    enable = mkEnableOption "PantherOS kernel security parameters";
    
    enableSysctlHardening = mkOption {
      type = types.bool;
      default = true;
      description = "Enable kernel sysctl hardening parameters";
    };
    
    enableGrsecurity = mkOption {
      type = types.bool;
      default = false;
      description = "Enable grsecurity-inspired kernel parameters (where applicable)";
    };
    
    # Memory protection settings
    enableASLR = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Address Space Layout Randomization";
    };
    
    enableExecShield = mkOption {
      type = types.bool;
      default = true;
      description = "Enable executable space protection like NX bit";
    };
    
    # Network security settings
    enableSynCookies = mkOption {
      type = types.bool;
      default = true;
      description = "Enable SYN cookies for SYN flood protection";
    };
    
    enableReversePathFilter = mkOption {
      type = types.bool;
      default = true;
      description = "Enable reverse path filtering to prevent IP spoofing";
    };
    
    enableIcmpRedirect = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to accept ICMP redirects";
    };
    
    enableSecureRedirect = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to accept secure ICMP redirects";
    };
    
    enableSendRedirect = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to send ICMP redirects";
    };
    
    # General kernel settings
    enableCoreDumps = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable core dumps (security risk)";
    };
    
    enablePanicOnOops = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to panic on kernel oops (security vs availability trade-off)";
    };
  };

  config = mkIf cfg.enable {
    # Kernel security parameters via sysctl
    boot.kernel.sysctl = mkIf cfg.enableSysctlHardening {
      # Memory protection
      "kernel.randomize_va_space" = mkIf cfg.enableASLR 2; # Full ASLR
      "kernel.exec-shield" = mkIf cfg.enableExecShield 1; # Enable exec-shield if available
      
      # Network security
      "net.ipv4.tcp_syncookies" = mkIf cfg.enableSynCookies 1;
      "net.ipv4.conf.all.rp_filter" = mkIf cfg.enableReversePathFilter 1;
      "net.ipv4.conf.default.rp_filter" = mkIf cfg.enableReversePathFilter 1;
      "net.ipv4.conf.all.accept_redirects" = mkIf cfg.enableIcmpRedirect 0;
      "net.ipv4.conf.default.accept_redirects" = mkIf cfg.enableIcmpRedirect 0;
      "net.ipv4.conf.all.secure_redirects" = mkIf cfg.enableSecureRedirect 0;
      "net.ipv4.conf.default.secure_redirects" = mkIf cfg.enableSecureRedirect 0;
      "net.ipv4.conf.all.send_redirects" = mkIf cfg.enableSendRedirect 0;
      "net.ipv4.conf.default.send_redirects" = mkIf cfg.enableSendRedirect 0;
      
      # Additional network security
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.conf.default.log_martians" = 1;
      "net.ipv4.tcp_timestamps" = 0; # Disable timestamps to prevent information disclosure
      
      # Network interface settings
      "net.ipv4.conf.all.accept_source_route" = mkIf cfg.enableGrsecurity 0;
      "net.ipv6.conf.all.accept_source_route" = mkIf cfg.enableGrsecurity 0;
      "net.ipv4.conf.all.arp_ignore" = 1;
      "net.ipv4.conf.all.arp_announce" = 2;
      
      # General security
      "kernel.kptr_restrict" = 2; # Hide kernel pointers
      "kernel.dmesg_restrict" = 1; # Restrict dmesg access
      "kernel.perf_event_paranoid" = 3; # Disable performance events for non-root
      "kernel.kexec_load_disabled" = mkIf cfg.enableGrsecurity 1;
      "kernel.yama.ptrace_scope" = 1; # Restrict ptrace
      "vm.mmap_rnd_bits" = 32; # Increase randomness for memory mapping
      "vm.mmap_rnd_compat_bits" = 16;
      
      # Core dumps configuration
      "fs.suid_dumpable" = mkIf (!cfg.enableCoreDumps) 0;
      
      # Panic settings
      "kernel.panic" = mkIf cfg.enablePanicOnOops 10; # Reboot after 10 seconds if panic
      "kernel.panic_on_oops" = mkIf cfg.enablePanicOnOops 1;
      
      # Exec buffer overflow protection
      "kernel.exec-shield" = mkIf cfg.enableExecShield 1;
      "kernel.randomize_va_space" = mkIf cfg.enableASLR 2;
    };
    
    # Additional kernel parameters
    boot = {
      # Kernel modules security
      kernelModules = [ "usb-storage" ]; # Explicitly allow needed modules
      
      # Kernel command line parameters
      kernelParams = mkIf cfg.enableExecShield [
        "noexec=on" # Enable execute-disable bit if available
      ];
    };
    
    # Additional security settings
    security = {
      # Restrict core dumps
      setuidBox = mkIf (!cfg.enableCoreDumps) {
        allowed = [ ]; # No setuid programs allowed unless explicitly configured elsewhere
      };
    };
  };
}