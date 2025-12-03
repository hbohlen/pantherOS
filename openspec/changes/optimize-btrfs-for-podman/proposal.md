# Optimize Btrfs for Podman Containers - Proposal

## Problem Statement

Current disko.nix configurations for Podman containers lack specific optimization strategies that account for container-specific I/O patterns. The existing approach often treats container storage as generic storage, leading to suboptimal performance for container workloads. This includes issues with Copy-on-Write (CoW) behavior, inefficient compression settings, and inadequate separation between different container storage needs (images, volumes, logs).

## Objective

Develop a comprehensive strategy for optimizing btrfs/disko.nix configurations specifically for Podman container workloads. This includes:
- Optimal storage driver analysis (overlay2 vs btrfs subvolumes)
- Subvolume layout design for container-specific needs
- Mount option optimization for container storage
- Snapshot and backup strategies for container data
- Performance characteristics analysis for different configurations

## Solution Overview

The solution will provide detailed guidance for configuring btrfs storage to maximize Podman container performance, considering factors like CoW behavior, container image storage, volume management, and logging strategies. It will include specific recommendations for subvolume layouts, mount options, and storage driver selection based on workload characteristics.

## Stakeholders

- System administrators deploying containerized applications
- Developers using Podman for development workflows
- Users running container workloads with specific performance requirements