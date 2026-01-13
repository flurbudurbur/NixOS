# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS system configuration using flakes with home-manager integration, organized following the i3-kickstarter modular pattern. The system is configured for user "flur" on hostname "flurPC".

## Build and Apply Commands

```bash
# Rebuild and switch to new configuration
sudo nixos-rebuild switch --flake .#flurPC

# Build without switching (test the build)
sudo nixos-rebuild build --flake .#flurPC

# Build and switch to new configuration on next boot
sudo nixos-rebuild boot --flake .#flurPC

# Update flake inputs (updates flake.lock)
nix flake update

# Update a specific input only
nix flake lock --update-input nixpkgs

# Check flake for errors without building
nix flake check
```

## Architecture

This configuration follows a clean, modular structure with clear separation of concerns:

```
nixos-system/
├── flake.nix              # Entry point - inputs and outputs
├── modules/               # System-level shared configuration
│   ├── colors.nix         # Rose Pine Moon color definitions
│   ├── system.nix         # Core system config (users, nix, fonts, services)
│   └── hyprland.nix       # Hyprland WM system setup
├── hosts/                 # Per-machine configurations
│   └── flurPC/
│       ├── default.nix    # Host-specific config (boot, networking)
│       └── hardware-configuration.nix  # Auto-generated hardware config
├── users/                 # Per-user configurations
│   └── flur/
│       ├── nixos.nix      # User-specific system settings
│       └── home.nix       # Imports home-manager modules
└── home/                  # Shared home-manager modules
    ├── core.nix           # Home basics (username, stateVersion, cursor)
    ├── programs/          # User programs and applications
    │   ├── default.nix    # Aggregates all program modules
    │   ├── git.nix        # Git and SSH configuration
    │   ├── common.nix     # User packages and utilities
    │   ├── xdg.nix        # GTK, Qt, XDG theming
    │   ├── nvim.nix       # Neovim configuration
    │   └── nixcord.nix    # Discord (currently disabled)
    ├── shell/             # Shell environment
    │   ├── default.nix    # Zsh configuration
    │   ├── terminals.nix  # Alacritty terminal
    │   ├── starship.nix   # Starship prompt
    │   ├── tmux.nix       # Tmux terminal multiplexer
    │   └── fastfetch.nix  # System info display
    └── wayland/           # Wayland/Hyprland specific
        ├── default.nix    # Aggregates wayland modules
        ├── hyprland/
        │   └── default.nix  # Hyprland settings
        ├── hyprlock.nix   # Lock screen
        ├── hypridle.nix   # Idle management
        ├── waybar/
        │   └── default.nix  # Status bar
        └── walker/
            └── default.nix  # App launcher
```

## Key Configuration Details

- **Window Manager**: Hyprland with UWSM integration
- **Display Manager**: regreet
- **GPU**: NVIDIA with open drivers
- **Theme**: Rose Pine Moon (system-wide)
- **Experimental Features**: Flakes and nix-command enabled
- **Unfree Packages**: Allowed (nixpkgs.config.allowUnfree = true)

## Special Flake Inputs

This configuration uses several external flake inputs beyond standard nixpkgs:

- **zen-browser**: Custom Firefox-based browser with zen modifications
- **nixcord**: Discord client configurator (currently disabled - see `home/programs/nixcord.nix`)
- **nixvim**: Neovim configuration framework used in `home/programs/nvim.nix`
- **nix-flatpak**: Declarative Flatpak package management
- **hypridle**: Pinned to main branch (fixes D-Bus crash after suspend)
- **nixpkgs-unstable**: Available for packages requiring newer versions

## Module Organization

### System-Level (modules/)
- `system.nix`: Core system configuration (Nix settings, users, fonts, services)
- `hyprland.nix`: Hyprland window manager and related packages
- `colors.nix`: Centralized Rose Pine Moon color definitions

### Host-Specific (hosts/flurPC/)
- `default.nix`: Boot loader, networking, hostname, imports system modules
- `hardware-configuration.nix`: Auto-generated, do not edit manually

### User-Specific (users/flur/)
- `nixos.nix`: User-specific system settings (currently empty)
- `home.nix`: Imports all home-manager modules

### Home-Manager (home/)
- `core.nix`: Basic home configuration (username, directory, cursor theme)
- `programs/`: Application configurations and user packages
- `shell/`: Shell, terminal, and CLI tool configurations
- `wayland/`: Hyprland and Wayland-specific configurations

## Workflow

1. **System Changes**: Edit files in `modules/` or `hosts/flurPC/`
2. **User Packages**: Add to `home/programs/common.nix`
3. **Program Configuration**: Create/edit files in appropriate `home/` subdirectory
4. **Apply Changes**: Run `sudo nixos-rebuild switch --flake .#flurPC`
5. **Test Before Applying**: Use `nixos-rebuild build --flake .#flurPC` first

## Adding New Modules

### New Program Configuration
1. Create file in `home/programs/yourprogram.nix`
2. Add import to `home/programs/default.nix`
3. Configure the program using home-manager options

### New System Service
1. Add configuration to `modules/system.nix` or `modules/hyprland.nix`
2. Rebuild to apply changes

### New Host
1. Create `hosts/newhostname/default.nix`
2. Copy `hardware-configuration.nix` from `/etc/nixos/`
3. Add configuration to `flake.nix`

## Color Theming

All colors are centralized in `modules/colors.nix` (Rose Pine Moon). To use colors in a module:

```nix
let
  c = import ../../modules/colors.nix;  # Adjust path as needed
in
{
  # Direct hex colors: c.base, c.text, c.rose, c.pine, c.foam, c.iris, etc.
  # ANSI terminal colors: c.ansi.black, c.ansi.red, etc.

  # Helper functions available:
  # - c.strip hex       -> removes '#' prefix
  # - c.hypr hex alpha  -> "rgba(232136ee)" format for Hyprland
  # - c.rgba hex alpha  -> "rgba(35, 33, 54, 0.9)" CSS format
  # - c.rgb hex         -> "rgb(35, 33, 54)" format for hyprlock
}
```

## Important Notes

- **Color imports**: Always use relative imports for colors.nix based on file location
- **Hostname parameter**: Keep `hostname = "flurPC"` in extraSpecialArgs for Hyprland monitor configs
- **State version**: "25.11" for both system and home-manager (do not change)
- **Hardware config**: Do not edit `hardware-configuration.nix` manually - regenerate if needed
- **nixcord status**: Currently disabled due to upstream issue #166 (see `home/programs/nixcord.nix`)
- **Home-manager backups**: Backup files use `.backup` extension (configured in flake.nix)
- **Flake structure**: Uses home-manager as a NixOS module, not standalone
