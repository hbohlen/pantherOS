# CI/CD Module

This module provides configuration for CI/CD infrastructure in pantherOS.

## Hercules CI Agent

The Hercules CI Agent enables continuous integration for NixOS configurations.

### Configuration

```nix
services.ci = {
  enable = true;
  
  herculesCI = {
    enable = true;
    clusterJoinTokenPath = "/var/lib/hercules-ci-agent/secrets/cluster-join-token.key";
    binaryCachesPath = "/var/lib/hercules-ci-agent/secrets/binary-caches.json";
  };
};
```

### Setup Steps

1. **Obtain Cluster Join Token**
   - Log in to your Hercules CI dashboard at https://hercules-ci.com
   - Navigate to your cluster settings
   - Generate a new cluster join token
   - Save it to the configured path on your system

2. **Configure Binary Caches**
   - Create a JSON file with your binary cache configuration
   - Example content:
     ```json
     {
       "mycache": {
         "kind": "CachixCache",
         "authToken": "your-cachix-auth-token"
       }
     }
     ```

3. **Set Proper Permissions**
   ```bash
   sudo chmod 600 /var/lib/hercules-ci-agent/secrets/cluster-join-token.key
   sudo chmod 600 /var/lib/hercules-ci-agent/secrets/binary-caches.json
   sudo chown -R hercules-ci-agent:hercules-ci-agent /var/lib/hercules-ci-agent
   ```

4. **Enable and Start the Service**
   ```bash
   sudo systemctl enable hercules-ci-agent
   sudo systemctl start hercules-ci-agent
   ```

### Verification

#### Automated Verification Script

Use the provided verification script to check agent connectivity:
```bash
./scripts/verify-hercules-ci.sh
```

The script will check:
- Service status (active/inactive)
- Presence of required secret files
- Service logs for connection messages
- Agent readiness to process tasks

For more detailed output:
```bash
./scripts/verify-hercules-ci.sh --verbose
```

For additional options:
```bash
./scripts/verify-hercules-ci.sh --help
```

#### Manual Verification

Check the service status:
```bash
sudo systemctl status hercules-ci-agent
```

View logs:
```bash
sudo journalctl -u hercules-ci-agent -f
```

Look for messages indicating:
- "Agent connected" or "Connected to"
- "Ready to process tasks" or "Waiting for jobs"

If you see error messages, check:
1. Secret files exist and have correct permissions
2. Cluster join token is valid
3. Network connectivity to Hercules CI servers

### Module Options

- `services.ci.enable` - Enable the CI/CD infrastructure
- `services.ci.herculesCI.enable` - Enable Hercules CI Agent
- `services.ci.herculesCI.clusterJoinTokenPath` - Path to cluster join token file
- `services.ci.herculesCI.binaryCachesPath` - Path to binary caches configuration

### Integration with OpNix

For secure secret management, you can integrate with OpNix to manage Hercules CI secrets:

```nix
services.onepassword-secrets = {
  secrets = {
    herculesToken = {
      reference = "op://pantherOS/hercules-ci/cluster-join-token";
      path = "/var/lib/hercules-ci-agent/secrets/cluster-join-token.key";
      owner = "hercules-ci-agent";
      group = "hercules-ci-agent";
      mode = "0600";
      services = ["hercules-ci-agent"];
    };
  };
};

services.ci = {
  enable = true;
  herculesCI = {
    enable = true;
    clusterJoinTokenPath = config.services.onepassword-secrets.secretPaths.herculesToken;
  };
};
```

### Documentation

After enabling the module, comprehensive documentation is available at:
- `/etc/hercules-ci/README`

### Examples

See the example configuration at:
- `docs/examples/hercules-ci-example.nix`

### Resources

- [Hercules CI Documentation](https://docs.hercules-ci.com)
- [Hercules CI Agent Configuration](https://docs.hercules-ci.com/hercules-ci-agent/configuration)
- [NixOS Hercules CI Agent Options](https://search.nixos.org/options?query=hercules-ci-agent)
