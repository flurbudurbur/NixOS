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
├── overlays/              # Nixpkgs overlays
│   ├── default.nix        # Aggregator - exports overlay sets (all, minimal, gaming)
│   ├── xone.nix           # Xbox controller kernel module override
│   └── custom-packages.nix # Adds custom packages to pkgs namespace
├── packages/              # Custom package definitions
│   ├── bricolage-grotesque.nix  # Custom font package
│   └── qobuz-player.nix         # TUI music player for Qobuz
├── modules/               # System-level shared configuration
│   ├── colors.nix         # Rose Pine Moon color definitions
│   ├── system.nix         # Core system config (users, nix, fonts, services)
│   ├── graphics.nix       # Graphics hardware (NVIDIA drivers, OpenGL)
│   ├── desktop.nix        # Desktop environment (Hyprland, regreet, XDG portals)
│   ├── gaming.nix         # Gaming (Steam, Lutris, Wine, gamemode)
│   └── secrets.nix        # System-level secrets management
├── hosts/                 # Per-machine configurations
│   └── flurPC/
│       ├── default.nix    # Host-specific config (boot, networking)
│       └── hardware-configuration.nix  # Auto-generated hardware config
└── users/                 # Per-user configurations
    └── flur/
        ├── nixos.nix      # User-specific system settings
        ├── home.nix       # Imports home-manager modules
        ├── core.nix       # Home basics (username, stateVersion, cursor)
        ├── secrets.nix    # User-level secrets management with sops-nix
        ├── programs/      # User programs and applications
        │   ├── default.nix    # Aggregates all program modules
        │   ├── git.nix        # Git and SSH configuration
        │   ├── packages.nix   # User packages and utilities
        │   ├── xdg.nix        # GTK, Qt, XDG theming
        │   ├── nvim.nix       # Neovim configuration
        │   ├── composer.nix   # PHP/Composer with hard-linked config
        │   ├── dev.nix        # Web development tools (fnm, pnpm, Node.js)
        │   ├── gpg.nix        # GPG configuration for Yubikey
        │   ├── zen-browser.nix  # Zen Browser with NextDNS integration
        │   ├── flatpak.nix    # Flatpak package declarations
        │   ├── mullvad-vpn.nix  # Mullvad VPN client
        │   ├── heroic.nix     # Heroic Games Launcher
        │   ├── persepolis.nix # Persepolis download manager
        │   └── nixcord.nix    # Discord (currently disabled)
        ├── shell/         # Shell environment
        │   ├── default.nix    # Zsh configuration
        │   ├── terminals.nix  # Foot terminal
        │   ├── starship.nix   # Starship prompt
        │   ├── tmux.nix       # Tmux terminal multiplexer
        │   └── fastfetch.nix  # System info display
        └── wayland/       # Wayland/Hyprland specific
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
- **Display Manager**: tuigreet
- **GPU**: NVIDIA with open drivers
- **Theme**: Rose Pine Moon (system-wide)
- **Experimental Features**: Flakes and nix-command enabled
- **Unfree Packages**: Allowed (nixpkgs.config.allowUnfree = true)

## Using Unstable Packages

While the system uses nixpkgs 25.11, unstable packages are available via `nixpkgs-unstable` parameter in home-manager:

```nix
{ pkgs, nixpkgs-unstable, ... }:
{
  home.packages = [
    nixpkgs-unstable.somePackage  # Use unstable version
    pkgs.normalPackage             # Use stable 25.11 version
  ];
}
```

This is configured in `flake.nix` extraSpecialArgs and allows mixing stable/unstable packages.

## Special Flake Inputs

This configuration uses several external flake inputs beyond standard nixpkgs:

- **zen-browser**: Custom Firefox-based browser with zen modifications
- **stylix**: System-wide theming framework (release-25.11 branch)
- **nixcord**: Discord client configurator (currently disabled - see `home/programs/nixcord.nix`)
- **nixvim**: Neovim configuration framework used in `home/programs/nvim.nix`
- **firefox-addons**: Firefox extensions from NUR (rycee's expressions)
- **nur**: Nix User Repository for additional packages
- **nix-flatpak**: Declarative Flatpak package management
- **nixpkgs-unstable**: Available for packages requiring newer versions
- **sops-nix**: Secret management with age encryption
- **nixos-secrets**: Private repository (`git@github.com:flurbudurbur/nix-secrets.git`) containing encrypted secrets
- **oxicord**: TUI Discord client (used in `disco` tmuxinator session)

## Module Organization

### System-Level (modules/)
- `system.nix`: Core system configuration (Nix settings, users, fonts, services)
- `graphics.nix`: Graphics hardware configuration (NVIDIA drivers, OpenGL/Vulkan)
- `desktop.nix`: Desktop environment (Hyprland WM, regreet DM, XDG portals, desktop apps)
- `gaming.nix`: Gaming configuration (Steam, Lutris, Wine, gamemode)
- `colors.nix`: Centralized Rose Pine Moon color definitions
- `secrets.nix`: System-level secrets management with sops-nix (age encryption)

### Host-Specific (hosts/flurPC/)
- `default.nix`: Boot loader, networking, hostname, imports system modules
- `hardware-configuration.nix`: Auto-generated, do not edit manually

### User-Specific (users/flur/)
All user-specific configuration lives under `users/flur/`:
- `nixos.nix`: User-specific system settings (currently empty)
- `home.nix`: Home-manager entry point (imports all modules below)
- `core.nix`: Basic home configuration (username, directory, cursor theme)
- `secrets.nix`: User-level secrets management with sops-nix
- `programs/`: Application configurations and user packages
- `shell/`: Shell, terminal, and CLI tool configurations
- `wayland/`: Hyprland and Wayland-specific configurations

## Workflow

1. **System Changes**: Edit files in `modules/` or `hosts/flurPC/`
2. **User Packages**: Add to `users/flur/programs/packages.nix`
3. **Program Configuration**: Create/edit files in appropriate `users/flur/` subdirectory
4. **Apply Changes**: Run `sudo nixos-rebuild switch --flake .#flurPC`
5. **Test Before Applying**: Use `nixos-rebuild build --flake .#flurPC` first

## Adding New Modules

### New Program Configuration
1. Create file in `users/flur/programs/yourprogram.nix`
2. Add import to `users/flur/programs/default.nix`
3. Configure the program using home-manager options

### New Custom Package
1. Create package in `packages/yourpackage.nix` using standard nixpkgs pattern:
   ```nix
   { lib, stdenv, fetchFromGitHub, ... }:
   stdenv.mkDerivation { ... }
   ```
2. Add to `overlays/custom-packages.nix`:
   ```nix
   yourpackage = final.callPackage ../packages/yourpackage.nix { };
   ```
3. Use in modules as `pkgs.yourpackage`

### New System Service
1. Add configuration to appropriate module:
   - Core services → `modules/system.nix`
   - Graphics/GPU → `modules/graphics.nix`
   - Desktop/WM → `modules/desktop.nix`
   - Gaming → `modules/gaming.nix`
2. Rebuild to apply changes

### New Host
1. Create `hosts/newhostname/default.nix`
2. Copy `hardware-configuration.nix` from `/etc/nixos/`
3. Add configuration to `flake.nix`

## Color Theming

All colors are centralized in `modules/colors.nix` (Rose Pine Moon) and passed globally via `specialArgs`/`extraSpecialArgs`.

**In home-manager modules** (programs/, shell/, wayland/):
```nix
{ config, colors, ... }:
{
  # Access colors directly from the colors parameter
  # Direct hex colors: colors.base, colors.text, colors.rose, colors.pine, colors.foam, colors.iris, etc.
  # ANSI terminal colors: colors.ansi.black, colors.ansi.red, etc.

  # Helper functions available:
  # - colors.strip hex       -> removes '#' prefix
  # - colors.hypr hex alpha  -> "rgba(232136ee)" format for Hyprland
  # - colors.rgba hex alpha  -> "rgba(35, 33, 54, 0.9)" CSS format
  # - colors.rgb hex         -> "rgb(35, 33, 54)" format for hyprlock
}
```

**In system modules** (modules/, hosts/):
```nix
{ config, colors, ... }:
{
  # Same access pattern - colors are passed via specialArgs
}
```

**Note**: The colors module was made global in commit 80fe6d1. Legacy relative imports (`import ../../../modules/colors.nix`) still work but are no longer necessary.

## Overlays and Custom Packages

Custom packages and nixpkgs modifications are organized in `/overlays/` and `/packages/`:

### Overlay Sets
The `overlays/default.nix` exports named sets for per-host selection:
- `overlays.all` — All overlays (NUR + xone + custom packages)
- `overlays.minimal` — Without gaming overlays (NUR + custom packages)
- `overlays.gaming` — Gaming-only (xone)

### Current Overlays
- **xone** (`overlays/xone.nix`): Overrides xone kernel module to use dlundqvist fork v0.5.7 for extra button support
- **custom-packages** (`overlays/custom-packages.nix`): Adds custom packages to pkgs namespace
- **nur**: NUR overlay (imported from flake input)

### Custom Packages (via `pkgs.*`)
- `pkgs.bricolage-grotesque` — Custom variable font
- `pkgs.qobuz-player` — TUI music player for Qobuz

### Per-Host Overlay Selection
```nix
# In flake.nix or host configuration
nixpkgs.overlays = overlays.all;      # Full overlays
nixpkgs.overlays = overlays.minimal;  # No gaming
nixpkgs.overlays = [ overlays.nur overlays.customPackages ];  # Manual selection
```

## Secrets Management with sops-nix

This configuration uses **sops-nix** for managing secrets with **age encryption**.

### Architecture
- **Secrets repository**: `git@github.com:flurbudurbur/nix-secrets.git` (separate from main config)
- **Encryption**: age key at `/root/.config/sops/age/keys.txt` (user copy at `/home/flur/.config/sops/age/keys.txt`)
- **System secrets**: Defined in `modules/secrets.nix` (Mullvad VPN configuration)
- **User secrets**: Defined in `users/flur/secrets.nix` (NextDNS URL, SSH hostname, Git signing key)

### Key Locations
- **System age key**: `/root/.config/sops/age/keys.txt` (private key for system secrets)
- **User age key**: `/home/flur/.config/sops/age/keys.txt` (user copy for home-manager secrets)
- **Public key**: `age1cnnmaf766jhumy92hqtgrxyr8z8vjymrj05j2k6hap57g3c50gmq2uhm36` (documented in nixos-secrets/README.md)

### Managing Secrets

**Edit secrets**:
```bash
cd /home/flur/nixos-secrets
export SOPS_AGE_KEY_FILE=/home/flur/.config/sops/age/keys.txt
sops secrets/user/nextdns.yaml
sops secrets/user/ssh-hosts.yaml
sops secrets/user/git-signing.yaml
sops secrets/system/mullvad/account-history.enc

# After editing
git add secrets/
git commit -m "Update secrets"
git push

# Update main config
cd /home/flur/nixos-system
nix flake lock --update-input nixos-secrets
sudo nixos-rebuild switch --flake .#flurPC  # No PIN required!
```

**Add new secrets**:
1. Create/encrypt file in nixos-secrets repo using age key
2. Add secret declaration to `modules/secrets.nix` (system) or `users/flur/secrets.nix` (user)
3. Reference secret in program config (see `users/flur/programs/git.nix` or `zen-browser.nix` for patterns)

### Program Integration Patterns

**Pattern 1: Read secret at evaluation time** (git.nix):
```nix
let
  secretFile = "${config.xdg.configHome}/sops-secrets/secret-name";
  secretValue = if builtins.pathExists secretFile
    then lib.removeSuffix "\n" (lib.fileContents secretFile)
    else "fallback-value";
in
```

**Pattern 2: Substitute at activation time** (zen-browser.nix):
```nix
# Use template marker in config
ProviderURL = "@TEMPLATE_VAR@";

# Add activation script
home.activation.substituteSecrets = lib.hm.dag.entryAfter ["writeBoundary"] ''
  ACTUAL_VALUE=$(cat "${config.xdg.configHome}/sops-secrets/secret-name")
  sed -i "s|@TEMPLATE_VAR@|$ACTUAL_VALUE|g" "$FILE"
'';
```

**Pattern 3: Hard-linked configuration** (composer.nix):
```nix
# composer.json is hard-linked between ~/.config/composer/ and repo root
# Activation script ensures both locations point to same inode
# Allows both NixOS tracking and standard composer workflow
home.activation.initComposer = lib.hm.dag.entryAfter ["writeBoundary"] ''
  # Creates hard link between repo and XDG config location
  ln "$REPO_COMPOSER" "$COMPOSER_JSON"
'';
```

### Deployment Notes
- **No interactive prompts**: age decryption works non-interactively during nixos-rebuild
- **Secrets location**:
  - System: Decrypted to paths specified in `modules/secrets.nix` (e.g., `/etc/mullvad-vpn/`)
  - User: Decrypted to `~/.config/sops-secrets/`
- **GPG still used**: Yubikey + GPG still used for Git commit signing (not for secret decryption)

### Migration History
- **Before 2026-01-19**: Used GPG key 59327CBED7938BDBE74B167D57CF006A8AD85F44 on Yubikey
- **After 2026-01-19**: Migrated to age encryption for automation-friendly operation
- **Reason**: GPG+Yubikey requires PIN entry which fails in systemd activation context

See `SOPS-NIX-SETUP.md` for detailed setup documentation and troubleshooting.

### Secrets Fallback Behavior

Modules that depend on secrets use graceful fallbacks for initial builds or when secrets are unavailable:

**Pattern: Check file existence before reading**
```nix
let
  secretFile = "${config.xdg.configHome}/sops-secrets/secret-name";
  secretValue = if builtins.pathExists secretFile
    then lib.removeSuffix "\n" (lib.fileContents secretFile)
    else "PLACEHOLDER";  # Fallback for initial build
in
```

This pattern allows:
1. Initial `nixos-rebuild` to succeed without decrypted secrets
2. Secrets to be deployed on first successful build
3. Subsequent rebuilds to use actual secret values

Modules using this pattern:
- `users/flur/programs/git.nix` - Git signing key ID
- `users/flur/programs/zen-browser.nix` - NextDNS URL (uses activation-time substitution)

## Shell Aliases & Functions

Defined in `users/flur/shell/default.nix`:

- `nrs` — `nixos-rebuild switch --sudo --flake` (apply config)
- `nrt` — `nixos-rebuild test --sudo --flake` (test without boot entry)
- `ncheck` — `nix flake check --no-build` (validate flake without building)
- `nfmt` — `nix fmt` (format Nix files using nixfmt-tree)
- `tmnix` — Start tmuxinator `dev` session in `~/nixos-system`
- `tmstart [dir] [session]` / `tmstop [dir] [session]` — Launch/stop named tmuxinator sessions

**Zoxide** is initialized in zsh (`eval "$(zoxide init zsh)"`), providing smart `z` directory jumping.

## Tmuxinator Sessions

Declarative tmuxinator YAML configs are managed as `xdg.configFile` entries in `users/flur/shell/tmux.nix`:

| Session | Purpose | Windows |
|---------|---------|---------|
| `dev`   | Development workflow | nvim, claude, lazygit, fastfetch |
| `netmon` | Network monitoring | bandwhich, iftop, nethogs |
| `disco` | Media/comms | oxicord (TUI Discord), kew (music) |

**Sesh** (`<prefix>t`) provides interactive tmux session switching with fzf, showing all sessions, tmuxinator configs, and zoxide directories.

## Security Wrappers for Network Tools

Network monitoring tools are given elevated capabilities in `modules/system.nix` via `security.wrappers` rather than sudoers entries:

```nix
security.wrappers = {
  bandwhich = { capabilities = "cap_net_raw,cap_net_admin+eip"; ... };
  nethogs   = { capabilities = "cap_net_raw,cap_net_admin+eip"; ... };
  iftop     = { capabilities = "cap_net_raw+eip"; ... };
};
```

This allows running these tools without a password prompt.

## Important Notes

- **Color access**: Colors are passed globally via specialArgs - use `colors` parameter instead of relative imports
- **Hostname parameter**: Keep `hostname = "flurPC"` in extraSpecialArgs for Hyprland monitor configs
- **State version**: "25.11" for both system and home-manager (do not change)
- **Hardware config**: Do not edit `hardware-configuration.nix` manually - regenerate if needed
- **Terminal**: Foot (replaced Alacritty) — configured in `users/flur/shell/terminals.nix`
- **nixcord status**: Currently disabled due to upstream issue #166 (see `users/flur/programs/nixcord.nix`)
- **Home-manager backups**: Backup files use `.backup` extension (configured in flake.nix)
- **Flake structure**: Uses home-manager as a NixOS module, not standalone
- **Secrets repo**: Never commit unencrypted secrets; see `.gitignore` in nixos-secrets repo
- **Custom packages**: Use `pkgs.bricolage-grotesque` and `pkgs.qobuz-player` instead of callPackage
