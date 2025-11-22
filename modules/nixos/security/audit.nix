{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.security.audit;
in
{
  options.pantherOS.security.audit = {
    enable = mkEnableOption "PantherOS security auditing tools";
    
    tools = {
      enableLynis = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Lynis security auditing tool";
      };
      
      enableAide = mkOption {
        type = types.bool;
        default = false;
        description = "Enable AIDE (Advanced Intrusion Detection Environment)";
      };
      
      enableAuditd = mkOption {
        type = types.bool;
        default = false;
        description = "Enable auditd for system call auditing";
      };
      
      enableTcpscan = mkOption {
        type = types.bool;
        default = false;
        description = "Enable TCP security scanning tools";
      };
    };
    
    enableAutomatedScanning = mkOption {
      type = types.bool;
      default = false;
      description = "Enable automated security scanning via systemd timers";
    };
    
    scanSchedule = mkOption {
      type = types.str;
      default = "weekly";
      description = "Schedule for automated security scans";
    };
  };

  config = mkIf cfg.enable {
    # Security auditing tools
    environment.systemPackages = with pkgs; [
      # Basic security tools
      nmap
      netcat
      whois
      dnsutils
      
      # Enable specific tools based on configuration
    ] ++ (mkIf cfg.tools.enableLynis [ lynis ])
    ++ (mkIf cfg.tools.enableAide [ aide ])
    ++ (mkIf cfg.tools.enableTcpscan [ pkgs.tcpdump ]);
    
    # Auditd configuration (system call auditing)
    services.auditd = mkIf cfg.tools.enableAuditd {
      enable = cfg.tools.enableAuditd;
      rules = [
        # Log all system calls that could indicate compromise
        "-a always,exit -F arch=b64 -S execve -k exec"
        "-a always,exit -F arch=b32 -S execve -k exec"
        "-w /etc/passwd -p wa -k etc_passwd"
        "-w /etc/group -p wa -k etc_group"
        "-w /etc/shadow -p wa -k etc_shadow"
        "-w /etc/security/ -p wa -k etc_security"
        "-w /var/log/ -p wa -k var_log"
        "-w /usr/bin/passwd -p x -k passwd"
        "-w /usr/bin/su -p x -k su"
        "-w /usr/bin/sudo -p x -k sudo"
        "-w /usr/bin/sudoedit -p x -k sudoedit"
        "-w /usr/bin/vim -p x -k vim"
        "-w /usr/bin/vi -p x -k vi"
        "-w /usr/bin/nano -p x -k nano"
      ];
    };
    
    # AIDE configuration for file integrity monitoring
    services.aide = mkIf cfg.tools.enableAide {
      enable = cfg.tools.enableAide;
      package = pkgs.aide;
      
      # Configuration for file integrity monitoring
      config = ''
        # Define the database location
        database=file:/var/lib/aide/aide.db
        database_out=file:/var/lib/aide/aide.db.new
        
        # Define the report location
        report_file=file:/var/log/aide/aide.log
        report_level=stdout
        report_email_addr=root@localhost
        
        # Define the report flags
        verbose=5
        
        # File properties to check
        FQDPPML  /bin/          R
        FQDPPML  /sbin/         R
        FQDPPML  /usr/bin/      R
        FQDPPML  /usr/sbin/     R
        FQDPPML  /etc/          R
        FQDPPML  /root/         R
        
        # Configuration files
        ALLXTRAHASHES  /etc/.*$
        ALLXTRAHASHES  /usr/bin/.*$
        ALLXTRAHASHES  /usr/sbin/.*$
        
        # Log files
        PERMS      /var/log/.*$
        PERMS      /var/mail/.*$
        
        # Ignore temporary files
        !/var/log/.*\.tmp$$
        !/var/log/.*\.swp$$
      '';
    };
    
    # Lynis configuration and automated scanning
    systemd = mkIf cfg.enableAutomatedScanning {
      # Timer for automated security scanning
      timers."security-scan" = mkIf (cfg.tools.enableLynis || cfg.tools.enableAide) {
        enable = true;
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.scanSchedule;
          Persistent = true;
        };
      };
      
      # Service for automated security scanning
      services."security-scan" = mkIf (cfg.tools.enableLynis || cfg.tools.enableAide) {
        enable = true;
        description = "Automated Security Scanning";
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
        
        script = let
          scanCommands = concatStringsSep "\n" (
            (mkIf cfg.tools.enableLynis [ "echo 'Running Lynis security scan...'; /run/current-system/sw/bin/lynis audit system --cronjob >> /var/log/lynis.log 2>&1" ])
            ++ (mkIf cfg.tools.enableAide [ 
              "echo 'Running AIDE integrity check...';",
              "/run/current-system/sw/bin/aide --check >> /var/log/aide.log 2>&1",
              "if [ $? -ne 0 ]; then",
              "  echo 'AIDE detected changes!' | mail -s 'AIDE Alert' root@localhost 2>/dev/null || true",
              "fi"
            ])
          );
        in ''
          #!/bin/sh
          set -e
          
          ${scanCommands}
          
          echo "Security scanning completed at $(date)"
        '';
      };
    };
    
    # Configuration for specific security tools
    environment.etc = mkIf cfg.tools.enableLynis {
      "lynis/lynis.conf".text = ''
        # PantherOS Lynis configuration
        [file]
        update-file = /var/lib/lynis/update
        plugin-directory = /usr/share/lynis/plugins
        include-tests = 
        skip-tests = 
        optional-tests = yes
        
        [network]
        test-timeout = 10
        connect-timeout = 10
        
        [tools]
        nmap = /run/current-system/sw/bin/nmap
        netstat = /run/current-system/sw/bin/netstat
        ss = /run/current-system/sw/bin/ss
        lsof = /run/current-system/sw/bin/lsof
        
        [logging]
        log-file = /var/log/lynis.log
        report-file = /var/log/lynis-report.dat
        show-overview = yes
        show-tests = no
        log-append = no
      '';
    };
    
    # Enable cron if automated scanning is enabled
    services.cron = mkIf cfg.enableAutomatedScanning {
      enable = true;
      systemCrontab = ''
        # Security scans based on schedule
        # This is handled by systemd timers instead
      '';
    };
  };
}