# Datadog Agent NixOS Module

## Enrichment Metadata

| Attribute | Value |
|-----------|-------|
| **Purpose** | System and application monitoring via Datadog agent |
| **Layer** | `modules/services/` |
| **Type** | NixOS service module |
| **Dependencies** | OpNix (for API key), network access |
| **Conflicts** | None (can coexist with other monitoring) |
| **Platforms** | `x86_64-linux`, `aarch64-linux` |
| **Maintenance** | Stable - follows nixpkgs datadog-agent module |

---

## Configuration Points

### Required
- `apiKeyFile`: Path to file containing Datadog API key (from OpNix)

### Optional
- `site`: Datadog site (datadoghq.com, datadoghq.eu, etc.)
- `hostname`: Override system hostname in Datadog
- `tags`: List of tags for this agent
- `logLevel`: DEBUG/INFO/WARN/ERROR
- `enableLiveProcessCollection`: Enable process monitoring
- `enableTraceAgent`: Enable APM tracing
- `checks`: Custom check configurations

---

## Code Implementation

```nix
# modules/services/datadog.nix
{ config, lib, pkgs, ... }:
let
  cfg = config.services.datadog-agent;
in
{
  options.pantherOS.datadog = {
    enable = lib.mkEnableOption "Datadog monitoring agent";
    
    tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Tags to apply to this Datadog agent";
      example = ["role:workstation" "owner:hayden"];
    };
  };

  config = lib.mkIf config.pantherOS.datadog.enable {
    services.datadog-agent = {
      enable = true;
      
      # API key from OpNix secret
      apiKeyFile = config.services.onepassword-secrets.secretPaths.datadogApiKey 
                   or "/run/secrets/datadog_api_key";
      
      # Site configuration (US by default, EU: datadoghq.eu)
      site = "datadoghq.com";
      
      # Tags
      tags = config.pantherOS.datadog.tags;
      
      # Optional: hostname override
      # hostname = config.networking.hostName;
      
      # Log level
      logLevel = "INFO";
      
      # Enable process collection (resource intensive)
      enableLiveProcessCollection = true;
      
      # Enable APM tracing
      enableTraceAgent = false;
      
      # Default checks (disk, network)
      diskCheck = {
        init_config = {};
        instances = [{ use_mount = "false"; }];
      };
      
      networkCheck = {
        init_config = {};
        instances = [{
          collect_connection_state = false;
          excluded_interfaces = ["lo" "lo0"];
        }];
      };
      
      # Custom checks can be added here
      checks = {
        # Example: HTTP health check
        # http_check = {
        #   init_config = null;
        #   instances = [{
        #     name = "service-health";
        #     url = "http://localhost:8080/health";
        #     tags = ["service:api"];
        #   }];
        # };
      };
    };
    
    # Ensure datadog user can read secrets
    users.users.datadog.extraGroups = lib.mkIf 
      (config.services.onepassword-secrets.enable or false)
      ["onepassword-secrets"];
  };
}
```

---

## Integration Pattern

### In Host Configuration

```nix
# hosts/yoga/default.nix
{ ... }:
{
  imports = [
    ../../modules/services/datadog.nix
  ];
  
  pantherOS.datadog = {
    enable = true;
    tags = [
      "role:workstation"
      "owner:hayden"
      "env:production"
    ];
  };
}
```

### With OpNix Secret

```nix
# modules/secrets/opnix.nix
services.onepassword-secrets.secrets = {
  datadogApiKey = {
    reference = "op://pantherOS/datadog/default/apiKey";
    variables.service = "datadog";
    services = ["datadog-agent"];
    mode = "0400";
  };
};
```

---

## Validation Steps

### 1. Build Check
```bash
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
```

### 2. Deploy and Verify Service
```bash
sudo nixos-rebuild switch --flake .#<host>
systemctl status datadog-agent
```

### 3. Check API Key Loading
```bash
# Verify secret file exists
sudo ls -l /var/lib/opnix/secrets/datadogApiKey

# Check service logs
journalctl -u datadog-agent -n 50
```

### 4. Verify Datadog Connection
```bash
# Check agent status
sudo datadog-agent status

# Verify connectivity
sudo datadog-agent check connectivity
```

### Expected Output:
- Service status: `active (running)`
- Logs: No API key errors
- Agent status: Connected to Datadog
- Host appears in Datadog dashboard with correct tags

---

## Troubleshooting

### API Key Issues
```bash
# Verify OpNix secret materialized correctly
sudo cat /var/lib/opnix/secrets/datadogApiKey

# Check datadog user can read it
sudo -u datadog cat /var/lib/opnix/secrets/datadogApiKey
```

### Service Won't Start
```bash
# Check detailed logs
journalctl -u datadog-agent -xe

# Verify configuration
sudo datadog-agent configcheck
```

### Tags Not Appearing
```nix
# Ensure tags are properly formatted (no spaces around colons)
tags = ["role:workstation" "env:prod"];  # Good
tags = ["role: workstation"];            # Bad
```

---

## Related Modules

- **OpNix Secrets**: [`opnix/nixos-secrets.nix.md`](../opnix/nixos-secrets.nix.md)
- **Tailscale**: [`services/tailscale.nix.md`](./tailscale.nix.md)
- **Secrets Management Guide**: [`SECRETS_MANAGEMENT_GUIDE.md`](../../implementation_guides/SECRETS_MANAGEMENT_GUIDE.md)

---

## Advanced Customization

### Multi-Environment API Keys

```nix
# Different API keys per environment
services.onepassword-secrets.secrets = {
  datadogApiKeyProd = {
    reference = "op://pantherOS/datadog/production/apiKey";
  };
  
  datadogApiKeyStaging = {
    reference = "op://pantherOS/datadog/staging/apiKey";
  };
};

# Select based on environment
services.datadog-agent.apiKeyFile = 
  if config.pantherOS.environment == "production"
  then config.services.onepassword-secrets.secretPaths.datadogApiKeyProd
  else config.services.onepassword-secrets.secretPaths.datadogApiKeyStaging;
```

### Custom Integrations

```nix
services.datadog-agent = {
  extraIntegrations = {
    postgres = pythonPackages: with pythonPackages; [
      psycopg2
    ];
  };
  
  checks.postgres = {
    init_config = {};
    instances = [{
      host = "localhost";
      port = 5432;
      username = "datadog";
      password_file = "/run/secrets/datadog_postgres_password";
      tags = ["db:primary"];
    }];
  };
};
```

---

## Performance Considerations

- **Live Process Collection**: Adds ~50-100MB RAM usage, disable if not needed
- **Trace Agent**: Only enable if using APM
- **Check Intervals**: Default 15s, increase for less critical metrics
- **Log Level**: Use INFO in production, DEBUG only for troubleshooting

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-15 | Initial enriched documentation |
