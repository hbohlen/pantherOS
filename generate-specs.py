#!/usr/bin/env python3
"""Generate pantherOS System Specifications document"""

# Header and Executive Summary
header = """# pantherOS System Specifications

**Project Name:** pantherOS  
**Short Description:** Declarative NixOS configuration system using Nix Flakes for reproducible, secure VPS deployments  
**Version:** 1.0  
**Last Updated:** 2025-11-17  
**Status:** Minimal working configuration with documented expansion path

---

## Executive Summary

This document provides implementation-oriented specifications for the pantherOS NixOS configuration system. It documents the **current minimal implementation** (not aspirational architecture) and provides clear boundaries, responsibilities, and configuration surfaces for each subsystem.

**Current Implementation Status:**
- ✅ Working: Single-host NixOS flake, disko disk management, SSH-only access, development shells
- ⚠️ Disabled: home-manager (closure size), OpNix secrets (initial deployment)
- ❌ Not Implemented: Modular architecture, desktop environment, monitoring, multiple active hosts

**Document Purpose:**
- Onboarding: Understand system architecture and components
- Maintenance: Know what each unit does and doesn't do
- Extension: Add features with clear boundaries and dependencies

---

## Section 1: Spec Index

| Unit Name | Purpose | Priority | Related Files |
|-----------|---------|----------|---------------|
| **NixOS Flake Layout** | Defines system configurations, inputs, and development shells | Must-have for onboarding | `flake.nix`, `flake.lock` |
| **Host Configuration System** | Individual server system configurations | Must-have for onboarding | `hosts/servers/*/configuration.nix` |
| **Disko Disk Management** | Declarative disk partitioning and filesystem setup | Must-have for onboarding | `hosts/servers/*/disko.nix` |
| **SSH-Only Remote Access** | Secure remote access without passwords | Important for maintenance | `configuration.nix` (services.openssh) |
| **Development Shells** | Language-specific development environments | Important for maintenance | `flake.nix` (devShells) |
| **MCP Server Integration** | AI-assisted development tooling | Important for maintenance | `.github/mcp-servers.json`, `.github/MCP-SETUP.md` |
| **Deployment Workflows** | Remote and local deployment procedures | Must-have for onboarding | `deploy.sh`, `DEPLOYMENT.md` |
| **Secrets Management (Planned)** | Secure secrets handling with OpNix/1Password | Nice-to-have / future | `flake.nix` (opnix input, disabled) |
| **Home Manager (Disabled)** | User environment and dotfile management | Nice-to-have / future | `hosts/servers/*/home.nix` (not loaded) |
| **Configuration Management Strategy** | How to organize, update, and test configurations | Important for maintenance | `README.md`, system_config/ |

---

## Section 2: Detailed Specifications

The following sections provide comprehensive specifications for each subsystem unit in pantherOS.

---
"""

# Write the file
with open('SYSTEM-SPECS.md', 'w') as f:
    f.write(header)
    
print("Created SYSTEM-SPECS.md header - continuing with full content...")
