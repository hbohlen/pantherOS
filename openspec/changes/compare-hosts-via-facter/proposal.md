# Compare Hosts via Facter - Proposal

## Problem Statement

Currently, our system lacks the capability to automatically compare two hosts based on their hardware configurations stored in facter.json and generate appropriate, host-specific disko.nix strategies. This leads to manual configuration processes that are time-consuming, error-prone, and not optimized for each host's specific hardware profile.

## Objective

Develop a system that can:
1. Compare two hosts via their facter.json data
2. Analyze hardware differences (CPU, RAM, storage, virtualization)
3. Generate optimal btrfs/disko.nix strategies tailored to each host
4. Determine appropriate subvolume layouts, mount options, and backup strategies based on hardware and workload profiles

## Solution Overview

The solution will involve creating a comparison tool that takes two facter.json files and their associated workload descriptions as input, then generates optimized disko.nix configurations for each host based on their hardware characteristics and intended use cases.

## Stakeholders

- System administrators who need to configure multiple hosts with different hardware
- DevOps engineers managing infrastructure with varying requirements
- Users requiring optimized storage strategies for different workloads