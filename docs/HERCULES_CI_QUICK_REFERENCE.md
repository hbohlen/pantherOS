# Hercules CI Quick Reference Card

Quick commands and common tasks for Hercules CI on pantherOS.

## Service Management

```bash
# Check service status
sudo systemctl status hercules-ci-agent

# View logs (real-time)
sudo journalctl -u hercules-ci-agent -f

# View recent logs
sudo journalctl -u hercules-ci-agent -n 50

# Restart service
sudo systemctl restart hercules-ci-agent

# Stop service
sudo systemctl stop hercules-ci-agent

# Start service
sudo systemctl start hercules-ci-agent
```

## Secret Management

```bash
# Check if secrets exist
sudo ls -la /var/lib/hercules-ci-agent/secrets/

# Verify secret permissions
sudo stat -c "%a %U:%G" /var/lib/hercules-ci-agent/secrets/cluster-join-token.key
sudo stat -c "%a %U:%G" /var/lib/hercules-ci-agent/secrets/binary-caches.json

# Refresh secrets from 1Password
sudo systemctl restart onepassword-secrets
sudo systemctl restart hercules-ci-agent
```

## Troubleshooting

```bash
# Check for errors in logs
sudo journalctl -u hercules-ci-agent -p err --no-pager

# Verify OpNix service
sudo systemctl status onepassword-secrets
sudo journalctl -u onepassword-secrets -n 20

# Test network connectivity
curl -v https://hercules-ci.com

# View service dependencies
systemctl show hercules-ci-agent | grep -E "(After|Wants|Requires)="
```

## Configuration Validation

```bash
# Check configuration syntax
nix-instantiate --parse hosts/servers/hetzner-vps/hercules-ci.nix

# Verify service is enabled
nix eval .#nixosConfigurations.hetzner-vps.config.services.ci.herculesCI.enable

# Check secret paths
nix eval .#nixosConfigurations.hetzner-vps.config.services.ci.herculesCI.clusterJoinTokenPath --raw
nix eval .#nixosConfigurations.hetzner-vps.config.services.ci.herculesCI.binaryCachesPath --raw

# Build test
nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel --dry-run
```

## 1Password Secrets Setup

Required structure in 1Password `pantherOS` vault:

**Item**: `hercules-ci`

**Fields**:
- `cluster-join-token`: Your Hercules CI agent token (string)
- `binary-caches`: JSON configuration for binary caches

**Example binary-caches content**:
```json
{
  "mycache": {
    "kind": "CachixCache",
    "authToken": "REPLACE_WITH_YOUR_CACHIX_AUTH_TOKEN"
  }
}
```

## Common Issues

### Agent Not Connecting
```bash
# Check if secrets are populated
sudo test -s /var/lib/hercules-ci-agent/secrets/cluster-join-token.key && echo "Token exists and has content"

# Verify OpNix is working
sudo systemctl status onepassword-secrets

# Restart both services
sudo systemctl restart onepassword-secrets && sleep 5 && sudo systemctl restart hercules-ci-agent
```

### Permission Errors
```bash
# Fix ownership and permissions
sudo chown -R hercules-ci-agent:hercules-ci-agent /var/lib/hercules-ci-agent
sudo chmod 700 /var/lib/hercules-ci-agent/secrets
sudo chmod 600 /var/lib/hercules-ci-agent/secrets/*
sudo systemctl restart hercules-ci-agent
```

### Service Won't Start
```bash
# Check dependencies
sudo systemctl status network-online.target
sudo systemctl status onepassword-secrets

# View detailed error
sudo journalctl -xeu hercules-ci-agent
```

## Configuration Files

| File | Purpose |
|------|---------|
| `hosts/servers/hetzner-vps/hercules-ci.nix` | Host configuration |
| `modules/ci/default.nix` | CI module |
| `ci.nix` | Hercules CI build config |
| `docs/HERCULES_CI_SETUP.md` | Setup guide |
| `docs/HERCULES_CI_VALIDATION.md` | Validation guide |

## Links

- **Hercules CI Dashboard**: https://hercules-ci.com
- **Documentation**: https://docs.hercules-ci.com
- **Setup Guide**: [docs/HERCULES_CI_SETUP.md](HERCULES_CI_SETUP.md)
- **Validation Guide**: [docs/HERCULES_CI_VALIDATION.md](HERCULES_CI_VALIDATION.md)

## Deployment

```bash
# Deploy from local machine
nixos-rebuild switch --flake .#hetzner-vps --target-host root@your-vps-ip

# Deploy from VPS
sudo nixos-rebuild switch --flake .#hetzner-vps
```

## Health Check Checklist

- [ ] Service is active: `sudo systemctl is-active hercules-ci-agent`
- [ ] No errors in logs: `sudo journalctl -u hercules-ci-agent -p err --no-pager`
- [ ] Secrets exist: `sudo ls /var/lib/hercules-ci-agent/secrets/`
- [ ] Correct permissions: `sudo stat -c "%a" /var/lib/hercules-ci-agent/secrets/cluster-join-token.key` (should be 600)
- [ ] Agent registered: Check Hercules CI dashboard
- [ ] Agent status: "Connected" or "Idle" in dashboard

## Emergency Recovery

```bash
# Complete reset of Hercules CI agent
sudo systemctl stop hercules-ci-agent
sudo rm -rf /var/lib/hercules-ci-agent/secrets/*
sudo systemctl restart onepassword-secrets
sleep 5
sudo systemctl start hercules-ci-agent

# View startup logs
sudo journalctl -u hercules-ci-agent -f
```

---

**Note**: For detailed troubleshooting and setup instructions, see [HERCULES_CI_SETUP.md](HERCULES_CI_SETUP.md)
