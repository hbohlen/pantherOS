# Raw Feature Description

## Feature Name
PantherOS Storage, Snapshots & Backup Foundation

## User Description

Initialize a new spec for PantherOS Storage, Snapshots & Backup Foundation.

This is a comprehensive feature to design a solid, reusable storage and backup foundation for PantherOS across all NixOS hosts (laptops and VPS servers), aligned with the product roadmap and new goals around modularization and testing.

Key context:
- Multi-host NixOS project with laptops (Zephyrus, Yoga) and VPS servers (Hetzner, Contabo, OVH)
- Uses Nix flakes with modular structure evolving toward flake-parts
- Disko for declarative partitioning and Btrfs subvolumes
- 1Password + OpNix for secrets
- CI/CD via GitHub Actions
- Monitoring via Datadog (primary) and optionally Prometheus/Grafana/Loki
- Growing testing story with unit tests and integration tests

This feature should tie into:
- Phase 4: Backup & Disaster Recovery
- Phase 5: Btrfs Optimization Suite
- Phase 5: Snapshot & Backup Automation
- Configuration Cleanup & Modularization
- Testing & Validation Framework (unit + integration)
- CI/Deploy/Caching improvements for multi-host

High-level goal: Create a storage and backup foundation that defines host "profiles" (laptop vs VPS) with tuned Disko + Btrfs layouts, provides clear strategies for subvolume layout, mount options, local snapshots, and offsite backups, and is expressed as modular NixOS modules wired via flake-parts.

## Source Reference
Location: /home/hbohlen/Downloads/pantherOS-main/plan-product.md
