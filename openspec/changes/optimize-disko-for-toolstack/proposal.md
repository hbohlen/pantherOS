# Optimize Disko for Specific Toolstack - Proposal

## Problem Statement

Current disko.nix configurations apply generic storage optimization strategies that don't account for specific toolstacks and workloads. This results in suboptimal performance for development environments with specific requirements for IDEs, browsers, containers, databases, and build systems. The lack of workload-aware configurations means slower project builds, decreased IDE responsiveness, and inefficient storage usage.

## Objective

Develop a system that generates optimized disko.nix configurations based on specific toolstacks and workloads, considering:
- IDEs and editors (Neovim, Zed) access patterns
- Browser storage requirements (cache, IndexedDB)
- Container runtimes (Podman) storage needs
- Database performance characteristics (PostgreSQL, MySQL, SQLite)
- Build system I/O patterns (Nix builds, compilation)
- Project directory locations (e.g., ~/dev)

## Solution Overview

The solution will analyze the host's toolstack and generate optimal btrfs subvolume layouts and mount options tailored to the specific combination of tools and services running on the host. This includes determining optimal compression settings, I/O scheduling, autodefrag settings, and snapshot strategies based on each workload's characteristics.

## Stakeholders

- Developers using the system who need responsive development environments
- System administrators deploying configurations across multiple host types
- Users running containers, databases, or other I/O intensive applications