# pantherOS Documentation

Welcome to the pantherOS documentation hub. This directory contains comprehensive documentation for the NixOS configuration project.

## Documentation Structure

### 📚 [Architecture](./architecture/)
System design and architectural decisions
- **[overview.md](./architecture/overview.md)** - High-level system architecture
- **host-classification.md** - Workstation vs server design patterns
- **security-model.md** - Tailscale, secrets, and firewall strategy
- **disk-layouts.md** - Btrfs sub-volume strategy across hosts
- **module-organization.md** - Modular structure rationale

### 🔧 [Guides](./guides/)
Step-by-step guides for common tasks
- **[hardware-discovery.md](./guides/hardware-discovery.md)** - How to scan and document hardware
- **[module-development.md](./guides/module-development.md)** - Creating and testing modules
- **[host-configuration.md](./guides/host-configuration.md)** - Configuring individual hosts
- **[testing-deployment.md](./guides/testing-deployment.md)** - Build, test, and deploy
- **[troubleshooting.md](./guides/troubleshooting.md)** - Common issues and solutions

### 💻 [Hardware](./hardware/)
Hardware specifications for all hosts
- **[yoga.md](./hardware/yoga.md)** - Lenovo Yoga 7 specifications
- **[zephyrus.md](./hardware/zephyrus.md)** - ASUS ROG Zephyrus specifications
- **[hetzner-vps.md](./hardware/hetzner-vps.md)** - Hetzner VPS specifications
- **[ovh-vps.md](./hardware/ovh-vps.md)** - OVH VPS specifications

### 🧩 [Modules](./modules/)
Module-specific documentation (mirrors `../modules/` structure)
- **[nixos/](./modules/nixos/)** - System modules documentation
  - **[core/](./modules/nixos/core/)** - Core system functionality
  - **[services/](./modules/nixos/services/)** - Network services
  - **[security/](./modules/nixos/security/) - Security configurations
  - **[hardware/](./modules/nytics/hardware/)** - Hardware-specific modules
- **[home-manager/](./modules/home-manager/)** - User modules documentation
  - **[shell/](./modules/home-manager/shell/)** - Terminal and shell
  - **[applications/](./modules/home-manager/applications/)** - User applications
  - **[development/](./modules/home-manager/development/)** - Dev tools and languages
  - **[desktop/](./modules/home-manager/desktop/)** - Desktop environment
- **[shared/](./modules/shared/)** - Shared modules documentation

### ✅ [TODOs](./todos/)
Task tracking and roadmap
- **[README.md](./todos/README.md)** - How to track and manage TODOs
- **phase1-hardware-discovery.md** - Phase 1: Hardware discovery tasks
- **phase2-module-development.md** - Phase 2: Module development tasks
- **phase3-host-configuration.md** - Phase 3: Host configuration tasks
- **research-tasks.md** - Research and exploration items
- **completed.md** - Completed tasks archive

## Documentation Reading Guide

### For AI Agents
1. **Start here**: Root `AGENTS.md` for project overview and rules
2. **Understand requirements**: Read `../brief.md` for complete project requirements
3. **Review architecture**: Read [architecture/overview.md](./architecture/overview.md)
4. **Check current tasks**: See [todos/](./todos/) for current work items
5. **Follow guides**: Use [guides/](./guides/) for step-by-step instructions

### For Developers
1. **Project overview**: `../README.md`
2. **Detailed requirements**: `../brief.md`
3. **Original vision**: `../pantherOS.md`
4. **Architecture**: [architecture/](./architecture/)
5. **Module guides**: [guides/module-development.md](./guides/module-development.md)

### For Each New Task
1. Check [todos/](./todos/) for task details
2. Review relevant architecture documentation
3. Read applicable guides
4. Check hardware specs if relevant
5. Review module documentation for patterns

## Key Documents at Repository Root

- **[`../README.md`](../README.md)** - Project overview and quick start
- **[`../brief.md`](../brief.md)** - Complete project requirements and specifications
- **[`../AGENTS.md`](../AGENTS.md)** - Agent guidance and best practices
- **[`../pantherOS.md`](../pantherOS.md)** - Original vision document with full TODOs

## Contributing to Documentation

When adding new features or modules:

1. **Update hardware docs** if hardware configuration changed
2. **Add module docs** in [modules/](./modules/) following existing patterns
3. **Update guides** if new procedures are required
4. **Track tasks** in [todos/](./todos/) and mark completed
5. **Update this README** if documentation structure changes

## Navigation Tips

- Use `git grep` to find documentation for specific features
- Check [todos/completed.md](./todos/completed.md) for precedent patterns
- Reference host-specific docs in [hardware/](./hardware/) for configuration examples
- Module documentation includes templates for new modules

---

**Need help?** Check the [troubleshooting guide](./guides/troubleshooting.md) or review the [architecture overview](./architecture/overview.md).
