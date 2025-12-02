# Troubleshooting Guide

Comprehensive troubleshooting guide for GitHub Copilot Coding Agent with NixOS setup.

## Table of Contents

- [SSH Connection Issues](#ssh-connection-issues)
- [Nix Build Failures](#nix-build-failures)
- [MCP Server Problems](#mcp-server-problems)
- [VPS Access Issues](#vps-access-issues)
- [Permission Errors](#permission-errors)
- [Disk Space Issues](#disk-space-issues)
- [Network Problems](#network-problems)
- [Configuration Errors](#configuration-errors)

---

## SSH Connection Issues

### Problem: Cannot connect to VPS

**Symptoms:**
```
ssh: connect to host xxx.xxx.xxx.xxx port 22: Connection refused
OR
Permission denied (publickey)
```

**Solutions:**

1. **Verify VPS is running**
   ```bash
   ping $VPS_HOST
   ```
   - If no response, check VPS status in control panel

2. **Check SSH key permissions**
   ```bash
   chmod 600 ~/.ssh/copilot_vps
   ls -la ~/.ssh/copilot_vps
   ```
   - Should show `-rw-------`

3. **Test with verbose output**
   ```bash
   ssh -vvv nixos-vps
   ```
   - Look for specific error messages

4. **Verify SSH service on VPS**
   - If you have console access:
   ```bash
   systemctl status sshd
   systemctl restart sshd
   ```

5. **Check firewall rules**
   ```bash
   # On VPS (via console)
   sudo iptables -L -n | grep 22
   ```

6. **Verify SSH config**
   ```bash
   cat ~/.ssh/config | grep -A 10 "Host nixos-vps"
   ```

### Problem: SSH key not recognized

**Symptoms:**
```
Permission denied (publickey)
```

**Solutions:**

1. **Verify public key on VPS**
   ```bash
   # Via console or alternate access
   cat ~/.ssh/authorized_keys
   ```

2. **Add public key to VPS**
   ```bash
   ssh-copy-id -i ~/.ssh/copilot_vps.pub user@vps-host
   ```

3. **Check key format**
   ```bash
   ssh-keygen -l -f ~/.ssh/copilot_vps
   ```
   - Should show key type and fingerprint

### Problem: Host key verification failed

**Symptoms:**
```
Host key verification failed
```

**Solutions:**

1. **Remove old host key**
   ```bash
   ssh-keygen -R $VPS_HOST
   ```

2. **Accept new host key**
   ```bash
   ssh -o StrictHostKeyChecking=accept-new nixos-vps
   ```

---

## Nix Build Failures

### Problem: Syntax error in Nix expression

**Symptoms:**
```
error: syntax error, unexpected ...
```

**Solutions:**

1. **Check syntax**
   ```bash
   nix flake check --show-trace
   ```

2. **Use language server**
   ```bash
   # In editor with nil/nixd
   # Check error highlighting
   ```

3. **Format code**
   ```bash
   nixpkgs-fmt path/to/file.nix
   ```

4. **Validate specific file**
   ```bash
   nix-instantiate --parse path/to/file.nix
   ```

### Problem: Package not found

**Symptoms:**
```
error: attribute 'packagename' missing
```

**Solutions:**

1. **Search for package**
   ```bash
   nix search nixpkgs packagename
   ```

2. **Check package exists**
   - Visit: https://search.nixos.org/packages

3. **Update flake inputs**
   ```bash
   nix flake update
   ```

4. **Check spelling and case**
   - Package names are case-sensitive

### Problem: Evaluation error

**Symptoms:**
```
error: infinite recursion encountered
OR
error: stack overflow
```

**Solutions:**

1. **Check for circular dependencies**
   - Review module imports
   - Look for mutual recursion

2. **Use builtins.trace for debugging**
   ```nix
   builtins.trace "Debug: ${toString value}" value
   ```

3. **Simplify expression**
   - Comment out parts to isolate issue

4. **Check attribute paths**
   ```bash
   nix eval .#nixosConfigurations.hetzner-vps.config.system.build --show-trace
   ```

### Problem: Build timeout

**Symptoms:**
```
error: build of '/nix/store/...' timed out
```

**Solutions:**

1. **Increase timeout**
   ```bash
   nix build --max-build-log-lines 100 --timeout 3600
   ```

2. **Check network connectivity**
   - May be downloading dependencies

3. **Use binary cache**
   ```bash
   # In nix.conf or flake
   substituters = https://cache.nixos.org
   ```

---

## MCP Server Problems

### Problem: MCP server not responding

**Symptoms:**
- Copilot doesn't use MCP features
- Timeout errors

**Solutions:**

1. **Verify Node.js installation**
   ```bash
   node --version
   npm --version
   ```
   - Should be v16+ for MCP servers

2. **Test npx access**
   ```bash
   npx -y cowsay hello
   ```

3. **Check specific MCP server**
   ```bash
   npx -y @modelcontextprotocol/server-sequential-thinking --version
   ```

4. **Clear npm cache**
   ```bash
   npm cache clean --force
   ```

### Problem: Brave Search MCP not working

**Symptoms:**
```
Error: BRAVE_API_KEY not set
OR
401 Unauthorized
```

**Solutions:**

1. **Verify API key is set**
   ```bash
   echo $BRAVE_API_KEY
   ```

2. **Check API key validity**
   - Log in to Brave Search API dashboard
   - Verify key is active

3. **Test API key directly**
   ```bash
   curl -H "X-Subscription-Token: $BRAVE_API_KEY" \
     "https://api.search.brave.com/res/v1/web/search?q=test"
   ```

4. **Check rate limits**
   - Free tier: 2,000 queries/month
   - May be rate limited

### Problem: MCP server crashes

**Symptoms:**
```
Error: spawn ENOENT
OR
Process exited with code 1
```

**Solutions:**

1. **Check logs**
   - Look in Copilot output panel

2. **Reinstall MCP server**
   ```bash
   npm cache clean --force
   npx -y @modelcontextprotocol/server-sequential-thinking
   ```

3. **Check system resources**
   ```bash
   free -h
   df -h
   ```

---

## VPS Access Issues

### Problem: Cannot push files to VPS

**Symptoms:**
```
rsync: connection unexpectedly closed
```

**Solutions:**

1. **Test SSH connection first**
   ```bash
   ssh nixos-vps 'echo "Connected"'
   ```

2. **Check rsync syntax**
   ```bash
   rsync -avz --dry-run ./ nixos-vps:~/pantherOS/
   ```

3. **Verify target directory exists**
   ```bash
   ssh nixos-vps 'mkdir -p ~/pantherOS'
   ```

4. **Check disk space on VPS**
   ```bash
   ssh nixos-vps 'df -h'
   ```

### Problem: Build fails on VPS but works locally

**Symptoms:**
- Local build succeeds
- VPS build fails

**Solutions:**

1. **Check Nix versions**
   ```bash
   nix --version
   ssh nixos-vps 'nix --version'
   ```

2. **Verify flake.lock is synced**
   ```bash
   # Ensure flake.lock is pushed to VPS
   rsync -avz flake.lock nixos-vps:~/pantherOS/
   ```

3. **Check system architecture**
   ```bash
   uname -m
   ssh nixos-vps 'uname -m'
   ```

4. **Review VPS-specific errors**
   ```bash
   ssh nixos-vps 'cd ~/pantherOS && nix build --show-trace'
   ```

---

## Permission Errors

### Problem: Cannot apply configuration

**Symptoms:**
```
error: you don't have permission to apply this configuration
```

**Solutions:**

1. **Check sudo access**
   ```bash
   ssh nixos-vps 'sudo -l'
   ```

2. **Add user to wheel group**
   ```bash
   # On VPS (as root or via console)
   sudo usermod -aG wheel username
   ```

3. **Configure sudoers**
   ```bash
   # On VPS (via console or root)
   sudo visudo
   # Add: %wheel ALL=(ALL) NOPASSWD: ALL
   ```

4. **Use correct command**
   ```bash
   # Must use sudo for switch
   ssh nixos-vps 'cd ~/pantherOS && sudo nixos-rebuild switch --flake .#hetzner-vps'
   ```

### Problem: Cannot write to Nix store

**Symptoms:**
```
error: cannot write to '/nix/store/...'
```

**Solutions:**

1. **Check Nix daemon**
   ```bash
   ssh nixos-vps 'systemctl status nix-daemon'
   ```

2. **Add to trusted users**
   ```nix
   # In configuration.nix
   nix.settings.trusted-users = [ "root" "@wheel" ];
   ```

3. **Verify Nix store ownership**
   ```bash
   ssh nixos-vps 'ls -la /nix/store | head'
   ```

---

## Disk Space Issues

### Problem: Not enough space for build

**Symptoms:**
```
error: No space left on device
```

**Solutions:**

1. **Check disk usage**
   ```bash
   ssh nixos-vps 'df -h'
   ```

2. **Clean up Nix store**
   ```bash
   ssh nixos-vps 'sudo nix-collect-garbage -d'
   ```

3. **Optimize store**
   ```bash
   ssh nixos-vps 'sudo nix-store --optimize'
   ```

4. **Delete old generations**
   ```bash
   ssh nixos-vps 'sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system'
   ```

5. **Check what's using space**
   ```bash
   ssh nixos-vps 'du -sh /nix/store/* | sort -rh | head -20'
   ```

### Problem: Nix store growing too large

**Solutions:**

1. **Enable automatic garbage collection**
   ```nix
   # In configuration.nix
   nix.gc = {
     automatic = true;
     dates = "weekly";
     options = "--delete-older-than 30d";
   };
   ```

2. **Set max store size**
   ```nix
   nix.settings.max-free = 1000000000; # 1GB free minimum
   nix.settings.min-free = 500000000;  # 500MB cleanup trigger
   ```

---

## Network Problems

### Problem: Cannot download dependencies

**Symptoms:**
```
error: unable to download 'https://...'
```

**Solutions:**

1. **Check network connectivity**
   ```bash
   ping cache.nixos.org
   ```

2. **Test HTTPS connection**
   ```bash
   curl -I https://cache.nixos.org
   ```

3. **Configure substituters**
   ```nix
   nix.settings.substituters = [
     "https://cache.nixos.org"
   ];
   ```

4. **Check firewall**
   ```bash
   ssh nixos-vps 'sudo iptables -L -n'
   ```

### Problem: Slow downloads

**Solutions:**

1. **Use closest mirror**
   ```nix
   nix.settings.substituters = [
     "https://cache.nixos.org"
     "https://nix-community.cachix.org"
   ];
   ```

2. **Enable parallel downloads**
   ```nix
   nix.settings.max-substitution-jobs = 4;
   ```

---

## Configuration Errors

### Problem: Option does not exist

**Symptoms:**
```
error: The option 'services.xxx' does not exist
```

**Solutions:**

1. **Search for correct option**
   ```bash
   nix search nixpkgs --json | jq
   ```
   - Or visit: https://search.nixos.org/options

2. **Check NixOS version**
   - Option may not exist in your version

3. **Check module imports**
   ```nix
   imports = [
     # Make sure required modules are imported
   ];
   ```

### Problem: Type mismatch

**Symptoms:**
```
error: value is a ... while a ... was expected
```

**Solutions:**

1. **Check type definition**
   - Look up option in NixOS manual

2. **Use correct type**
   ```nix
   # String vs list
   services.foo.bar = "string";     # Not ["string"]
   services.foo.baz = [ "item" ];   # Not "item"
   ```

3. **Use lib functions**
   ```nix
   lib.mkForce value      # Override
   lib.mkDefault value    # Default
   lib.mkIf condition     # Conditional
   ```

---

## Quick Diagnostic Commands

### System Health Check

```bash
# Local
nix flake check
nix doctor

# VPS
ssh nixos-vps 'systemctl --failed'
ssh nixos-vps 'journalctl -p err -b'
```

### Build Diagnostics

```bash
# Verbose build
nix build --show-trace --print-build-logs

# Check what would be built
nix build --dry-run

# Evaluate without building
nix eval .#nixosConfigurations.hetzner-vps.config.networking.hostName
```

### Network Diagnostics

```bash
# Test connectivity
ping cache.nixos.org
curl -I https://cache.nixos.org

# Check DNS
dig cache.nixos.org
```

### Storage Diagnostics

```bash
# Local
df -h /nix/store
du -sh ~/.cache/nix

# VPS
ssh nixos-vps 'df -h /nix/store'
ssh nixos-vps 'nix-store --gc --print-dead'
```

---

## Getting Help

If you can't resolve your issue:

1. **Check logs**
   ```bash
   journalctl -xe
   nix log <derivation>
   ```

2. **Search existing issues**
   - GitHub Issues
   - NixOS Discourse
   - Stack Overflow

3. **Ask for help**
   - Include error messages
   - Show relevant config
   - Describe what you've tried

4. **Resources**
   - NixOS Manual: https://nixos.org/manual/nixos/stable/
   - NixOS Discourse: https://discourse.nixos.org/
   - NixOS Wiki: https://nixos.wiki/

---

## Common Error Messages Reference

| Error | Common Cause | Quick Fix |
|-------|--------------|-----------|
| `infinite recursion` | Circular dependency | Review imports |
| `attribute missing` | Wrong package name | Search nixpkgs |
| `Permission denied` | SSH key issue | Check key permissions |
| `No space left` | Disk full | Run garbage collection |
| `Connection refused` | VPS down or firewall | Check VPS status |
| `build timeout` | Network or slow build | Increase timeout |
| `option does not exist` | Wrong NixOS version | Check option docs |

---

## Version: 1.0.0
Last Updated: 2025-12-02
