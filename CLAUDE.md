# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS system configuration using flakes with home-manager integration. The system is configured for user "flur" on hostname "flurPC".

## Build and Apply Commands

```bash
# Rebuild and switch to new configuration
sudo nixos-rebuild switch --flake .#flurPC

# Build without switching (test the build)
sudo nixos-rebuild build --flake .#flurPC

# Build and switch to new configuration on next boot
sudo nixos-rebuild boot --flake .#flurPC
```

## Architecture

- **flake.nix**: Entry point defining inputs (nixpkgs 25.11, home-manager 25.11) and the system configuration
- **configuration.nix**: System-level NixOS configuration (boot, networking, system packages, services, hardware)
- **home.nix**: User-level configuration via home-manager (user packages, dotfiles, program configs)
- **hardware-configuration.nix**: Auto-generated hardware config (do not edit manually - imports from /etc/nixos/)

## Key Configuration Details

- Uses Hyprland as window manager with ly display manager
- NVIDIA GPU with open drivers enabled
- Flakes and nix-command experimental features enabled
- Unfree packages allowed (nixpkgs.config.allowUnfree = true)

## Workflow

1. Edit configuration files as needed
2. Run `sudo nixos-rebuild switch --flake .#flurPC` to apply changes
3. System packages go in `configuration.nix` under `environment.systemPackages`
4. User packages go in `home.nix` under `home.packages`
5. Program-specific configs (git, bash, ssh, etc.) go in `home.nix` under `programs`
