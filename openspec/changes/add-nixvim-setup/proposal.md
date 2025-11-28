# Change: add-nixvim-setup

## Why

As a beginner Neovim user with ADHD, I need a properly configured Neovim setup that helps me learn Vim motions effectively and provides quality-of-life improvements. The current system uses basic vim, but nixvim would allow declarative configuration and access to powerful plugins that help with focus, organization, and learning.

## What Changes

- Add nixvim flake input to flake.nix
- Configure nixvim in the NixOS configuration with essential plugins for beginners
- Add hardtime.nvim and precognition.nvim as required plugins
- Add additional recommended plugins for ADHD-friendly development
- Replace basic vim with nixvim as the default editor

## Impact

- Affected specs: neovim capability (new)
- Affected code: flake.nix, hosts/servers/hetzner-vps/configuration.nix
- Breaking change: EDITOR environment variable changes from vim to nvim</content>
  <parameter name="filePath">openspec/changes/add-nixvim-setup/proposal.md
