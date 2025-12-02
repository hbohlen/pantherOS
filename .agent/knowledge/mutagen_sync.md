# Mutagen Synchronization

## Overview

**Mutagen** is used in **pantherOS** to provide high-performance, real-time file synchronization and network forwarding, particularly useful for remote development workflows (e.g., syncing between the laptop and a VPS).

## Configuration

- **Module**: `modules/development/mutagen/`
- **Key Files**:
  - `default.nix`: Main module definition, service setup, and package installation.
  - `sync.nix`: Configuration for file synchronization sessions.
  - `forward.nix`: Configuration for port forwarding.
  - `projects.nix`: Project-specific configurations.

## Features

- **System Integration**:
  - Installs `mutagen`, `mutagen-compose`, and `docker-compose`.
  - Configures `virtualisation.docker` (moved from `services` to `virtualisation` block).
  - Sets up `openssh` with specific settings for sync (e.g., `PasswordAuthentication = false`).
- **Services**:
  - `mutagen-daemon`: Runs the Mutagen daemon as a user service.
  - `mutagen-session-manager`: Automatically creates sessions defined in `~/.config/mutagen/`.
  - `mutagen-session-cleanup`: Terminates sessions on shutdown.
- **Shell Aliases**:
  - `ms`: `mutagen sync`
  - `mf`: `mutagen forward`
  - `ml`: `mutagen sync list`
  - `mm`: `mutagen sync monitor`

## Usage

Mutagen sessions are typically defined declaratively or managed via the CLI aliases. The system ensures the daemon is running and sessions are managed according to the configuration.
