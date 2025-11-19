# Guides

Step-by-step guides for working with pantherOS.

## Available Guides

### 🖥️ [Hardware Discovery](./hardware-discovery.md)
How to scan and document hardware specifications for all hosts.

**Learn how to:**
- Scan hardware on workstations and servers
- Document specifications in standardized format
- Use hardware data for optimization
- Plan disk layouts based on hardware

**Start here if:** You need to configure a new host or update hardware documentation

### 🧩 [Module Development](./module-development.md)
Creating and testing NixOS and home-manager modules.

**Learn how to:**
- Create single-concern modules
- Structure module hierarchies
- Write module options and implementations
- Test modules before integration

**Start here if:** You need to add new functionality or create a module

### 🏠 [Host Configuration](./host-configuration.md)
Configuring individual hosts with specific optimizations.

**Learn how to:**
- Configure a host from scratch
- Apply host-specific optimizations
- Integrate with Tailscale and secrets management
- Validate host configuration

**Start here if:** You're setting up or modifying a specific host

### ✅ [Testing and Deployment](./testing-deployment.md)
Building, testing, and deploying configurations safely.

**Learn how to:**
- Test builds before deploying
- Use build, dry-run, and switch commands
- Rollback on errors
- Verify deployments

**Start here if:** You're ready to deploy changes

### 🔧 [Troubleshooting](./troubleshooting.md)
Common issues and their solutions.

**Find help with:**
- Build failures
- Configuration errors
- Hardware issues
- Recovery procedures

**Start here if:** You're encountering errors or issues

## Guide Usage

### For Each Task:
1. Read the relevant guide
2. Follow steps in order
3. Run verification commands
4. Check troubleshooting if needed
5. Update documentation if you discover new information

### Prerequisites
- Basic understanding of NixOS
- Access to the repository
- Read `../brief.md` for project requirements
- Review `../architecture/overview.md` for design context

### Verification
Each guide includes verification steps. Always verify your work:
```bash
# Test build
nixos-rebuild build .#<hostname>

# Check configuration
nixos-rebuild dry-activate --flake .#<hostname>
```

## Contributing to Guides

When you solve a problem:
1. Document the solution in troubleshooting.md if it's a new issue
2. Update the relevant guide if the procedure changed
3. Add examples or clarifications where helpful
4. Test your documentation by following it yourself

## Quick Reference

| Task | Guide |
|------|-------|
| New hardware to configure | [Hardware Discovery](./hardware-discovery.md) |
| Add new feature/system | [Module Development](./module-development.md) |
| Configure a specific host | [Host Configuration](./host-configuration.md) |
| Ready to deploy | [Testing and Deployment](./testing-deployment.md) |
| Something broke | [Troubleshooting](./troubleshooting.md) |

---

**Need help?** Start with [Troubleshooting](./troubleshooting.md) or review the [architecture overview](../architecture/overview.md).
