# NixOS Configuration

Personal NixOS configuration with Hyprland, Rose Pine Moon theming, and comprehensive flakes-based system management.

## Stack

- **WM**: Hyprland (Wayland) with UWSM integration
- **DM**: tuigreet (Wayland greeter)
- **Shell**: Fish + Starship prompt + Zoxide
- **Terminal**: Foot + Tmux
- **Editor**: Neovim (nixvim configuration)
- **Browser**: Zen Browser (Firefox-based) + NextDNS integration
- **GPU**: NVIDIA open drivers
- **Theme**: Multi-theme with runtime switching (rose-pine-moon, catppuccin-mocha, sweet)
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
├── overlays/              # Nixpkgs overlays
│   ├── default.nix        # Aggregator (exports: all, minimal, gaming)
│   ├── xone.nix           # Xbox controller kernel module override
│   └── custom-packages.nix # Adds custom packages to pkgs namespace
├── packages/              # Custom package definitions
│   ├── bricolage-grotesque.nix  # Custom font (pkgs.bricolage-grotesque)
│   ├── qobuz-player.nix        # TUI music player (pkgs.qobuz-player)
│   └── rose-pine-plymouth.nix  # Plymouth boot theme (pkgs.rose-pine-plymouth)
├── dotfiles/              # Shared dotfile sources
│   └── starship.toml      # Starship prompt base config (extended by theme switcher)
├── modules/               # System-level configuration
│   ├── themes/
│   │   └── default.nix    # Theme color palettes (rose-pine-moon, catppuccin-mocha, sweet)
│   ├── system.nix         # Core system (users, nix, fonts, services)
│   ├── graphics.nix       # NVIDIA drivers, OpenGL/Vulkan
│   ├── desktop.nix        # Hyprland, tuigreet, XDG portals
│   ├── gaming.nix         # Steam, Lutris, Wine, gamemode
│   ├── keyd.nix           # Keyboard remapping (default + Razer Tartarus)
│   ├── opentabletdriver.nix # Drawing tablet support (OpenTabletDriver)
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
        │   ├── git.nix        # Git configuration
        │   ├── ssh.nix        # SSH with FIDO2/Yubikey keys
        │   ├── nvim.nix       # Neovim (nixvim)
        │   ├── dev.nix        # fnm, pnpm, Node.js
        │   ├── zen-browser.nix # Zen Browser + NextDNS
        │   └── ...
        ├── shell/         # Fish, Starship, Tmux
        └── wayland/       # Hyprland, Waybar, Walker, Hyprlock, Mako, Themes
```

## Key Features

### Development Tools
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

Runtime theme switching across all apps via `theme-switch [name]`:

- Theme palettes defined in `modules/themes/default.nix` (rose-pine-moon, catppuccin-mocha, sweet)
- Per-app config files generated by `users/flur/wayland/themes.nix` under `~/.config/themes/<name>/`
- Active theme symlinked at `~/.config/themes/current`
- Apps source their theme file at runtime (CSS imports, Lua dofile, INI includes)
- `theme-switch` reloads Hyprland, Waybar, Walker, Mako, Foot, Neovim, GTK, and Zen Browser

## Notable Flake Inputs

- **nixpkgs**: NixOS 26.05 (stable)
- **nixpkgs-unstable**: For bleeding-edge packages
- **home-manager**: Release 26.05
- **zen-browser**: Custom Firefox-based browser
- **nixvim**: Neovim configuration framework
- **stylix**: System-wide theming (release-26.05)
- **nix-flatpak**: Declarative Flatpak management
- **sops-nix**: Secret management with age encryption
- **nixos-secrets**: Private secrets repository
- **walker** + **elephant**: Application launcher
- **fluxer**: Custom fluxer releases

## Network Configuration

- **Wireless**: NetworkManager
- **Firewall**: Configured in system modules

## Adding New Modules

### User Package
1. Add to `users/flur/programs/packages.nix`
2. Rebuild: `sudo nixos-rebuild switch --flake .#flurPC`

### Custom Package
1. Create `packages/yourpackage.nix` using standard nixpkgs pattern
2. Add to `overlays/custom-packages.nix`: `yourpackage = final.callPackage ../packages/yourpackage.nix { };`
3. Use as `pkgs.yourpackage` in any module

### Program Configuration
1. Create `users/flur/programs/yourprogram.nix`
2. Import in `users/flur/programs/default.nix`
3. Rebuild

### System Service
1. Edit appropriate module in `modules/` (system.nix, graphics.nix, etc.)
2. Rebuild

## Important Notes

- **State Version**: 25.11 (system and home-manager — do not change)
- **Hostname**: `flurPC` (passed as `extraSpecialArgs` for monitor configs)
- **Backup Extension**: `.backup` (home-manager conflicts)
- **Hardware Config**: Auto-generated, do not edit manually
- **GPG Key**: Used only for Git signing, not secret decryption
- **Age Migration**: Switched from GPG to age on 2026-01-19 for automation-friendly secrets
- **Custom Packages**: Available via `pkgs.bricolage-grotesque`, `pkgs.qobuz-player`, `pkgs.rose-pine-plymouth`

## Documentation

- Full setup details: See `CLAUDE.md`
- Secrets setup: See `SOPS-NIX-SETUP.md`
- Theming: See `modules/themes/default.nix` and `users/flur/wayland/themes.nix`

## System Information

- **NixOS**: 26.05
- **Architecture**: x86_64-linux
- **User**: flur
- **Hostname**: flurPC
