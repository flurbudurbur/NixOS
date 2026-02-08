# NixOS Configuration

Personal NixOS configuration with Hyprland, Rose Pine Moon theming, and comprehensive flakes-based system management.

## Stack

- **WM**: Hyprland (Wayland) with UWSM integration
- **DM**: regreet (Wayland greeter)
- **Shell**: Zsh + Starship prompt
- **Terminal**: Alacritty + Tmux
- **Editor**: Neovim (nixvim configuration)
- **Browser**: Zen Browser (Firefox-based) + NextDNS integration
- **GPU**: NVIDIA open drivers
- **Theme**: Rose Pine Moon (system-wide)
- **Security**: sops-nix (age encryption) + GPG/Yubikey for Git signing

## Quick Commands

```bash
# Rebuild and switch to new configuration
sudo nixos-rebuild switch --flake .#flurPC

# Build without switching (test first)
sudo nixos-rebuild build --flake .#flurPC

# Build and switch on next boot
sudo nixos-rebuild boot --flake .#flurPC

# Update all flake inputs
nix flake update

# Update specific input only
nix flake lock --update-input nixpkgs

# Check flake for errors
nix flake check
```

## Secrets Management

This configuration uses **sops-nix** with **age encryption** for secret management.

### Locations
- **Secrets repo**: `git@github.com:flurbudurbur/nix-secrets.git` (separate from main config)
- **Encryption key**: `/home/flur/.config/sops/age/keys.txt`
- **Public key**: `age1cnnmaf766jhumy92hqtgrxyr8z8vjymrj05j2k6hap57g3c50gmq2uhm36`

### Managing Secrets

```bash
# Edit secrets
cd ~/nixos-secrets
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
sops secrets/user/nextdns.yaml
sops secrets/user/ssh-hosts.yaml

# Apply changes
git add secrets/ && git commit -m "Update secrets" && git push
cd ~/nixos-system
nix flake lock --update-input nixos-secrets
sudo nixos-rebuild switch --flake .#flurPC
```

### Current Secrets
- **System**: Mullvad VPN account configuration
- **User**: NextDNS URL, SSH hostnames, Git GPG signing key

## Project Structure

```
nixos-system/
├── flake.nix              # Entry point - inputs and outputs
├── modules/               # System-level configuration
│   ├── system.nix         # Core system (users, nix, fonts, services)
│   ├── graphics.nix       # NVIDIA drivers, OpenGL/Vulkan
│   ├── desktop.nix        # Hyprland, regreet, XDG portals
│   ├── gaming.nix         # Steam, Lutris, Wine, gamemode
│   ├── colors.nix         # Rose Pine Moon color definitions
│   └── secrets.nix        # System-level secrets (sops-nix)
├── hosts/                 # Per-machine configurations
│   └── flurPC/
│       ├── default.nix    # Boot, networking, hostname
│       └── hardware-configuration.nix
└── users/                 # Per-user configurations
    └── flur/
        ├── nixos.nix      # User-specific system settings
        ├── home.nix       # Home-manager entry point
        ├── core.nix       # Basic home configuration
        ├── secrets.nix    # User-level secrets
        ├── programs/      # Application configs
        │   ├── git.nix        # Git + SSH + GPG
        │   ├── nvim.nix       # Neovim (nixvim)
        │   ├── composer.nix   # PHP/Composer with hard-linked config
        │   ├── dev.nix        # fnm, pnpm, Node.js
        │   ├── zen-browser.nix # Zen Browser + NextDNS
        │   └── ...
        ├── shell/         # Zsh, Starship, Tmux, Fastfetch
        └── wayland/       # Hyprland, Waybar, Walker, Hyprlock
```

## Key Features

### Development Tools
- **PHP**: Composer with hard-linked `composer.json` (tracked in repo + XDG config)
- **Node.js**: fnm (Fast Node Manager) + pnpm
- **Git**: Yubikey GPG signing, SSH aliases
- **Neovim**: Comprehensive nixvim configuration

### Gaming
- Steam (with gamescope)
- Lutris
- Heroic Games Launcher
- Wine + gamemode

### Desktop Applications
- Zen Browser (Firefox-based with NextDNS)
- Mullvad VPN
- Persepolis (download manager)
- Flatpak integration

### Hyprland Configuration
- Monitor configurations per hostname
- Waybar status bar
- Walker app launcher
- Hyprlock screen locker
- Hypridle idle management

## Theming

All colors centralized in `modules/colors.nix` (Rose Pine Moon palette). Import with:

```nix
let
  c = import ../../modules/colors.nix;  # Adjust path as needed
in
{
  # Use: c.base, c.text, c.rose, c.pine, c.foam, c.iris, etc.
  # Helper functions: c.strip, c.hypr, c.rgba, c.rgb
}
```

## Notable Flake Inputs

- **nixpkgs**: NixOS 25.11 (stable)
- **nixpkgs-unstable**: For bleeding-edge packages
- **home-manager**: Release 25.11
- **zen-browser**: Custom Firefox-based browser
- **nixvim**: Neovim configuration framework
- **stylix**: System-wide theming
- **nix-flatpak**: Declarative Flatpak management
- **sops-nix**: Secret management with age encryption
- **nixos-secrets**: Private secrets repository

## Network Configuration

- **Wireless**: NetworkManager
- **Firewall**: Configured in system modules

## Adding New Modules

### User Package
1. Add to `users/flur/programs/packages.nix`
2. Rebuild: `sudo nixos-rebuild switch --flake .#flurPC`

### Program Configuration
1. Create `users/flur/programs/yourprogram.nix`
2. Import in `users/flur/programs/default.nix`
3. Rebuild

### System Service
1. Edit appropriate module in `modules/` (system.nix, graphics.nix, etc.)
2. Rebuild

## Important Notes

- **State Version**: 25.11 (system and home-manager)
- **Hostname**: `flurPC` (passed as `extraSpecialArgs` for monitor configs)
- **Backup Extension**: `.backup` (home-manager conflicts)
- **Hardware Config**: Auto-generated, do not edit manually
- **nixcord**: Currently disabled (upstream issue #166)
- **GPG Key**: Used only for Git signing, not secret decryption
- **Age Migration**: Switched from GPG to age on 2026-01-19 for automation-friendly secrets

## Documentation

- Full setup details: See `CLAUDE.md`
- Secrets setup: See `SOPS-NIX-SETUP.md`
- Color theming: See `modules/colors.nix`

## System Information

- **NixOS**: 25.11
- **Kernel**: 6.12.68
- **Nix**: 2.31.2
- **Architecture**: x86_64-linux
- **User**: flur
- **Hostname**: flurPC
