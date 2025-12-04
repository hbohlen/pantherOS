# Architectural Decision Records (ADR) Index

> **Purpose:** Track all major technical decisions made in the PantherOS project  
> **Format:** Lightweight ADRs linked to OpenSpec  
> **Status:** Active tracking

## What is an ADR?

An Architectural Decision Record (ADR) captures important architectural decisions along with their context and consequences.

## ADR Status Labels

- 🟢 **Accepted**: Decision made and implemented
- 🟡 **Proposed**: Under consideration  
- 🔴 **Deprecated**: No longer valid
- ⚪ **Superseded**: Replaced by another ADR

---

## Index of Decisions

### Configuration & Build System
- ADR-001: Use NixOS for System Configuration 🟢
- ADR-002: Use Flakes for Configuration Management 🟢
- ADR-003: Modular Configuration Structure 🟢

### Secrets Management
- ADR-004: Use 1Password + OpNix for Secrets 🟢

### Networking & Infrastructure
- ADR-005: Use Tailscale for Host Networking 🟢
- ADR-006: SSH Hardening Configuration 🟢

### CI/CD & Deployment
- ADR-007: Dual CI/CD with GitHub Actions Primary 🟢
- ADR-008: Use Attic for Binary Caching 🟡
- ADR-009: Manual Deployment with Approval Gates 🟢

### Desktop Environment
- ADR-010: DankMaterialShell + Niri for Desktop 🟡
- ADR-011: Fish as Primary Shell 🟢
- ADR-012: Ghostty as Terminal Emulator 🟡

### Storage & Filesystems
- ADR-013: BTRFS with Subvolumes 🟡
- ADR-014: Disable CoW for Nix Store and Containers 🟡

### Development Tools
- ADR-015: Nixvim for Neovim Configuration 🟢
- ADR-016: Zed IDE as Secondary Editor 🟡

**Total ADRs:** 16 (12 accepted, 4 proposed)

---

For full details, see individual ADR files in this directory or the consolidated ADR document.

**Last Updated:** 2025-12-04
