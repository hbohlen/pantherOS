# Recommend Optimal Btrfs Compression Settings Per Subvolume - Proposal

## Problem Statement

Current btrfs configurations use inconsistent or suboptimal compression settings across subvolumes. The selection of compression levels (zstd:1 vs zstd:3 vs zstd:6) lacks a systematic approach that balances CPU costs, performance, and disk usage. Without proper guidance, system administrators apply generic settings that may not be optimal for their specific hardware capabilities, data types, and storage constraints. This leads to inefficient resource usage and missed opportunities for space savings.

## Objective

Develop a systematic approach to recommend optimal btrfs compression settings for each subvolume based on:
- Host CPU capabilities (core count, type) to balance CPU overhead
- Data type characteristics (source code, DB files, logs, container images, binaries, etc.)
- Storage constraints and usage patterns
- Performance requirements versus space efficiency goals

## Solution Overview

The solution will provide a decision matrix that recommends appropriate compression levels based on hardware profiles and data types. It will include a CPU vs compression trade-off analysis, compression ratio expectations for different data types, and explicit recommendations for when compression should be disabled altogether. The system will calculate approximate effective capacity gains from the chosen compression strategy.

## Stakeholders

- System administrators configuring storage systems
- DevOps engineers optimizing system resources
- Users seeking to balance performance and storage efficiency