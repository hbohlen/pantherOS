# Design Snapshot and Backup Strategy for Btrfs Layout - Proposal

## Problem Statement

Current disko.nix configurations lack a comprehensive, documented strategy for snapshots and backups. While some hosts have basic btrfs snapshot capabilities mentioned in comments, there's no systematic approach that considers different data criticality tiers, Recovery Point Objectives (RPO), Recovery Time Objectives (RTO), and hardware constraints. Without a proper strategy, users risk data loss or extended downtime during system failures, and lack a consistent approach to protecting different types of data across subvolumes.

## Objective

Develop a comprehensive snapshot and backup strategy that:
- Defines which subvolumes to snapshot and backup based on data criticality
- Establishes appropriate frequencies and retention policies
- Designs backup procedures that fit within available disk space
- Creates clear recovery procedures for different scenarios
- Includes validation procedures to ensure backups are functional

## Solution Overview

The solution will provide a systematic approach to btrfs snapshot and backup strategy that considers host type (laptop/server/VPS), data criticality tiers, RPO/RTO requirements, and available disk space. It will include specific recommendations for snapshot frequencies, retention policies, backup procedures (local vs remote), and recovery runbooks for different scenarios.

## Stakeholders

- System administrators responsible for data protection
- Users managing multiple hosts with different criticality levels
- DevOps engineers requiring consistent backup strategies across environments