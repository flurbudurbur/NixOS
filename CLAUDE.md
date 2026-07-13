# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS system configuration using flakes with home-manager integration, organized following the i3-kickstarter modular pattern. It manages two hosts: **flurPC** (desktop, Hyprland) and **vps** (headless netcup server).

## Build and Apply Commands

Rebuilds use [nh](https://github.com/nix-community/nh) (configured in `modules/system.nix`; `NH_FLAKE` points at this repo, so no flake path argument is needed). nh self-elevates via sudo and prints an nvd package diff after each rebuild.

```bash
# Rebuild and switch to new configuration
nh os switch

# Apply without creating a boot entry (test without switching default)
nh os test

# Build and switch to new configuration on next boot
nh os boot

# Update flake inputs and switch in one step
nh os switch --update

# Apply to the VPS remotely (build locally, activate over SSH)
nixos-rebuild switch --flake .#vps --target-host root@<vps-ip> --build-host localhost

# Update flake inputs (updates flake.lock)
nix flake update

# Update a specific input only
nix flake lock --update-input nixpkgs

# Check flake for errors without building
nix flake check

# Search packages / clean old generations
nh search <query>
nh clean all --keep 5 --keep-since 7d
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
│   ├── qobuz-player.nix        # TUI music player for Qobuz
│   └── rose-pine-plymouth.nix  # Plymouth boot theme
├── dotfiles/              # Shared dotfile sources
│   └── starship.toml      # Starship prompt base config (extended by theme switcher)
├── modules/               # System-level shared configuration
│   ├── themes/
│   │   └── default.nix    # Theme color definitions (rose-pine-moon, catppuccin-mocha, sweet)
│   ├── base.nix           # Host-agnostic core config (users, nix, fish, base packages) - imported by every host
│   ├── server.nix         # Headless-server concerns (firewall, sshd hardening, fail2ban, qemuGuest) - vps only
│   ├── relay.nix          # Public relay profile (WireGuard hub for homelab spokes) - vps now, portable to a future dedicated relay host
│   ├── graphics.nix       # Graphics hardware (NVIDIA drivers, OpenGL) - flurPC only
│   ├── desktop.nix        # Desktop/GUI environment (Hyprland, tuigreet, audio, bluetooth, fonts, OpenRGB) - flurPC only
│   ├── gaming.nix         # Gaming (Steam, Lutris, Wine, gamemode) - flurPC only
│   ├── keyd.nix           # Keyboard remapping (default keyboard + Razer Tartarus) - flurPC only
│   ├── opentabletdriver.nix # Drawing tablet support (OpenTabletDriver) - flurPC only
│   └── secrets.nix        # System-level secrets management
├── hosts/                 # Per-machine configurations
│   ├── flurPC/
│   │   ├── default.nix    # Host-specific config (boot, networking)
│   │   └── hardware-configuration.nix  # Auto-generated hardware config
│   └── vps/
│       ├── default.nix    # Host-specific config (GRUB, networking, KVM guest modules)
│       ├── disko.nix      # Declarative disk layout for nixos-anywhere provisioning
│       └── services/      # App config specific to this one machine (not reusable roles - see below)
│           ├── caddy.nix
│           ├── searxng.nix
│           ├── syncyomi.nix
│           └── flur34.nix
└── users/                 # Per-user configurations
    └── flur/
        ├── nixos.nix      # User-specific system settings
        ├── common/        # Shared between desktop/ and vps/ profiles
        │   ├── git.nix
        │   └── ssh.nix    # SSH configuration with FIDO2/Yubikey keys
        ├── desktop/       # flurPC home-manager profile
        │   ├── home.nix       # Entry point (imports everything else in desktop/)
        │   ├── core.nix       # Home basics (username, stateVersion, cursor, stylix)
        │   ├── secrets.nix    # User-level secrets management with sops-nix
        │   ├── programs/      # Application configurations and user packages
        │   │   ├── default.nix    # Aggregates program modules (pulls git.nix/ssh.nix from ../../common/)
        │   │   ├── packages.nix   # User packages and utilities
        │   │   ├── xdg.nix        # GTK, Qt, XDG theming
        │   │   ├── nvim.nix       # Neovim configuration
        │   │   ├── dev.nix        # Web development tools (fnm, pnpm, Node.js)
        │   │   ├── gpg.nix        # GPG configuration for Yubikey
        │   │   ├── zen-browser.nix  # Zen Browser with NextDNS integration
        │   │   ├── flatpak.nix    # Flatpak package declarations
        │   │   ├── mullvad-vpn.nix  # Mullvad VPN client
        │   │   ├── heroic.nix     # Heroic Games Launcher
        │   │   └── persepolis.nix # Persepolis download manager
        │   ├── shell/         # Shell environment
        │   │   ├── default.nix    # Fish configuration (aliases, functions, starship, fastfetch)
        │   │   ├── terminals.nix  # Foot terminal
        │   │   └── tmux.nix       # Tmux terminal multiplexer
        │   └── wayland/       # Wayland/Hyprland specific
        │       ├── default.nix    # Aggregates wayland modules
        │       ├── hyprland.nix   # Hyprland settings (Lua config)
        │       ├── hyprlock.nix   # Lock screen
        │       ├── hypridle.nix   # Idle management
        │       ├── timeouts.nix   # Shared timeout values for hypridle/hyprlock
        │       ├── mako.nix       # Notification daemon
        │       ├── themes.nix     # Runtime theme switcher (generates per-theme config files)
        │       ├── waybar.nix     # Status bar
        │       └── walker.nix     # App launcher
        └── vps/           # vps home-manager profile
            └── home.nix       # Minimal entry point (git/ssh from ../common/, shell basics) - no GUI/wayland
```

## Key Configuration Details

- **Window Manager**: Hyprland with UWSM integration
- **Display Manager**: tuigreet
- **GPU**: NVIDIA with open drivers
- **Theme**: Multi-theme with runtime switching (rose-pine-moon, catppuccin-mocha, sweet); default rose-pine-moon
- **Experimental Features**: Flakes and nix-command enabled
- **Unfree Packages**: Allowed (nixpkgs.config.allowUnfree = true)

## Using Unstable Packages

While the system uses nixpkgs 26.05, unstable packages are available via `nixpkgs-unstable` parameter in home-manager:

```nix
{ pkgs, nixpkgs-unstable, ... }:
{
  home.packages = [
    nixpkgs-unstable.somePackage  # Use unstable version
    pkgs.normalPackage             # Use stable 26.05 version
  ];
}
```

This is configured in `flake.nix` extraSpecialArgs and allows mixing stable/unstable packages.

## Special Flake Inputs

This configuration uses several external flake inputs beyond standard nixpkgs:

- **zen-browser**: Custom Firefox-based browser with zen modifications
- **stylix**: System-wide theming framework (release-26.05 branch)
- **nixvim**: Neovim configuration framework used in `users/flur/desktop/programs/nvim.nix`
- **firefox-addons**: Firefox extensions from NUR (rycee's expressions)
- **nur**: Nix User Repository for additional packages
- **nix-flatpak**: Declarative Flatpak package management
- **nixpkgs-unstable**: Available for packages requiring newer versions
- **sops-nix**: Secret management with age encryption
- **nixos-secrets**: Private repository (`git@github.com:flurbudurbur/nix-secrets.git`) containing encrypted secrets
- **fluxer**: Custom fluxer releases
- **walker** + **elephant**: Application launcher with elephant dependency
- **home-manager**: Home-manager (release-26.05 branch)

## Module Organization

### System-Level (modules/)
- `base.nix`: Host-agnostic core configuration (Nix settings, user account, fish, nix-ld, base packages, podman, network-monitor wrappers). Imported by **every** host.
- `server.nix`: Headless-server concerns (firewall, sshd hardening, fail2ban, qemuGuest, nix.gc). Imported by `vps` only.
- `relay.nix`: Public relay profile — WireGuard hub (`wg0`, 10.100.0.1/24, UDP 51820) that homelab spokes (flurLab, flurPC, phone) dial into; hub forwards spoke↔spoke traffic. Private key via sops (`secrets/system/relay/wireguard.yaml`, key `relay-wg-key`) with fallback `/etc/wireguard/wg0.key`. Imported by `vps` today; designed to move as-is to a future dedicated relay host (future public homelab-service vhosts belong here too).
- `graphics.nix`: Graphics hardware configuration (NVIDIA drivers, OpenGL/Vulkan). `flurPC` only.
- `desktop.nix`: Desktop/GUI environment (Hyprland WM, tuigreet DM, XDG portals, audio, bluetooth, fonts, gnome-keyring, OpenRGB). `flurPC` only.
- `gaming.nix`: Gaming configuration (Steam, Lutris, Wine, gamemode). `flurPC` only.
- `keyd.nix`: Keyboard remapping (capslock/ctrl swap, Razer Tartarus profiles). `flurPC` only.
- `opentabletdriver.nix`: Drawing tablet support (OpenTabletDriver daemon). `flurPC` only.
- `themes/default.nix`: Theme color palettes (rose-pine-moon, catppuccin-mocha, sweet)
- `secrets.nix`: System-level secrets management with sops-nix (age encryption)

The `base.nix`/`desktop.nix`/`server.nix` split mirrors the `overlays.all`/`overlays.minimal` pattern: generic config lives in one place, hardware/GUI-only config in another, so a new host only imports what applies to it.

### Host-Specific (hosts/)
- `flurPC/default.nix`: Boot loader (systemd-boot), networking (NetworkManager), imports `base.nix` + `graphics.nix` + `desktop.nix` + `gaming.nix` + `keyd.nix` + `opentabletdriver.nix`.
- `flurPC/hardware-configuration.nix`: Auto-generated, do not edit manually.
- `vps/default.nix`: Boot loader (GRUB, BIOS legacy - device supplied automatically by disko), KVM guest kernel modules, imports `base.nix` + `server.nix` + everything under `vps/services/`.
- `vps/disko.nix`: Declarative disk layout (GPT: BIOS-boot + ESP + ext4 root) consumed by `nixos-anywhere` at provisioning time — there is no hand-written `hardware-configuration.nix` for this host.
- `vps/services/`: App config specific to this one machine, as opposed to `modules/` which holds *reusable roles* (things that could plausibly apply to a hypothetical second desktop or server). These aren't reusable in that sense - they're one-off to this VPS - so they live under the host, not in `modules/`:
  - `caddy.nix`: Reverse proxy for `srx.flur.dev` (SearXNG), `flur34.com`/`beta.flur34.com` (KuroSearch containers, see `flur34.nix`), `sync.shiori.gg` (SyncYomi), `dev.shiori.gg` (static). Built with the `caddy-dns/cloudflare` plugin for DNS-01 challenges; also carries the `caddy-wordpress` fail2ban jail (misleadingly named - it's generic bot-probe banning for all the Caddy sites, not WordPress-specific). Needs `secrets/system/vps/caddy.yaml` added to `nix-secrets` (see file for the expected key/format) - falls back to `/etc/caddy/cloudflare.env` (populate manually) until then.
  - `searxng.nix`: SearXNG + Valkey as `virtualisation.oci-containers` (rootful podman, unlike the original rootless per-user quadlets). After first deploy, copy the synced `settings.yml`/`limiter.toml` into `/var/lib/searxng/`.
  - `syncyomi.nix`: SyncYomi sync server as a plain systemd service (no nixpkgs module for it, just the package). Session secret is sops-managed once `secrets/system/vps/syncyomi.yaml` exists; until then a random one is generated and persisted under `/var/lib/syncyomi`.
  - `flur34.nix`: KuroSearch (`ghcr.io/flur34/flur34`) as two `virtualisation.oci-containers` - `flur34` (`:latest`, port 8181) and `flur34-beta` (`:canary`, port 8383, watchtower-update-enabled). Real rule34 API creds go in `secrets/system/vps/{flur34,flur34-beta}.yaml`; falls back to an editable placeholder at `/etc/flur34/*.env` until those exist. Watchtower itself (the thing beta's `/update` webhook on :8384 talks to) isn't declared anywhere yet - it wasn't in the synced compose files, presumably a separate shared instance.

  Migrated from the netcup box's home directory; everything under `*.flur.me` (conduwuit, coturn, LiveKit) and MariaDB/php8.3-fpm were retired, not migrated.

### User-Specific (users/flur/)
Split into `common/` (shared between both profiles), `desktop/` (flurPC), and `vps/` (the vps host) - same username on both machines, but the profiles themselves don't overlap beyond `common/`:
- `nixos.nix`: User-specific system settings (currently empty)
- `common/git.nix`, `common/ssh.nix`: The only two files genuinely identical across both hosts (SSH config with FIDO2/Yubikey keys, git config/signing). `vps/home.nix` still overrides some options from these (e.g. disables `commit.gpgsign` - no Yubikey on a server) rather than forking the files.
- `desktop/home.nix`: Entry point, imports `core.nix`, `programs/`, `shell/`, `wayland/`, `secrets.nix`.
- `desktop/core.nix`: Basic home configuration (username, directory, cursor theme, stylix).
- `desktop/secrets.nix`: User-level secrets management with sops-nix.
- `desktop/programs/`: Application configurations and user packages (pulls `git.nix`/`ssh.nix` in from `../../common/`).
- `desktop/shell/`: Shell, terminal, and CLI tool configurations.
- `desktop/wayland/`: Hyprland and Wayland-specific configurations.
- `vps/home.nix`: Minimal entry point - `common/` git+ssh, a small fish/starship/eza/zoxide config. No GUI, no `programs/` aggregate.

## Workflow

1. **System Changes**: Edit files in `modules/` or `hosts/flurPC/`
2. **User Packages**: Add to `users/flur/programs/packages.nix`
3. **Program Configuration**: Create/edit files in appropriate `users/flur/` subdirectory
4. **Apply Changes**: Run `nh os switch`
5. **Test Before Applying**: Use `nh os test` first (applies without a boot entry)

## Adding New Modules

### New Program Configuration
1. Create file in `users/flur/desktop/programs/yourprogram.nix`
2. Add import to `users/flur/desktop/programs/default.nix` (desktop) and/or `users/flur/vps/home.nix` (server) as applicable
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
   - Generic/host-agnostic → `modules/base.nix`
   - Server-only → `modules/server.nix`
   - Graphics/GPU → `modules/graphics.nix`
   - Desktop/WM/GUI hardware → `modules/desktop.nix`
   - Gaming → `modules/gaming.nix`
2. Rebuild to apply changes

### New Host
1. Create `hosts/newhostname/default.nix`, importing `modules/base.nix` plus whichever of `desktop.nix`/`server.nix`/etc. apply
2. For a physical/manually-installed machine: copy `hardware-configuration.nix` from `/etc/nixos/`. For a cloud VPS: write a `disko.nix` instead (see `hosts/vps/disko.nix`) and provision with `nixos-anywhere`
3. Add a `nixosConfigurations.<name>` entry to `flake.nix`, picking `overlays.all`/`overlays.minimal` and either `users/flur/desktop/home.nix` (desktop) or `users/flur/vps/home.nix` (headless) for the home-manager profile

## Provisioning the VPS (netcup, via nixos-anywhere + disko)

The `vps` host isn't running NixOS yet — bring it up from netcup's rescue system:

1. Boot the netcup rescue system, note its IP, and check `[ -d /sys/firmware/efi ]` to confirm legacy BIOS vs UEFI (the `vps/default.nix` GRUB config currently assumes legacy BIOS — flip `efiSupport` and switch `disko.nix`'s ESP mountpoint if it's UEFI). Also confirm the disk device name via `lsblk` matches `hosts/vps/disko.nix` (`/dev/vda` assumed).
2. From this repo: `nix run github:nix-community/nixos-anywhere -- --flake .#vps root@<rescue-ip>` — this partitions the disk per `disko.nix` and installs the `vps` configuration directly.
3. Add the VPS's own age key as a `.sops.yaml` recipient in the `nix-secrets` repo before referencing any secrets from `modules/secrets.nix` on this host (don't reuse the desktop's private key across machines).
4. For subsequent updates, use `nixos-rebuild switch --flake .#vps --target-host root@<vps-ip> --build-host localhost` from this repo rather than building on the VPS itself.

## Color Theming

Theming uses a **runtime theme switcher** with multiple themes defined in `modules/themes/default.nix`. Each theme is an attrset with standardized field names:

```nix
{
  bg, bg_alt, bg_select,     # Background shades
  fg_faint, fg_dim, fg,      # Foreground shades
  error, warning,            # Status colors
  accent2, blue, cyan, accent, # Accent colors
  hl_low, hl_med, hl_high,  # Highlight shades
}
```

### How it works

1. `modules/themes/default.nix` defines color palettes (rose-pine-moon, catppuccin-mocha, sweet)
2. `users/flur/desktop/wayland/themes.nix` generates per-theme config files for each app (hyprland, waybar, walker, foot, starship, mako, hyprlock, zen browser, nvim, gtk) under `~/.config/themes/<name>/`. Starship base config is sourced from `dotfiles/starship.toml`
3. `~/.config/themes/current` is a symlink to the active theme
4. Apps source their theme file at runtime (e.g. `@import url("~/.config/themes/current/waybar-style.css")`)
5. `theme-switch [name]` updates the symlink and reloads all apps

### Adding a new theme
1. Add the color palette to `modules/themes/default.nix`
2. Optionally add a wallpaper to `wallpapers/<name>.{jpg,png,webp,gif}`
3. Rebuild — theme files are auto-generated for all apps

### System-level colors
`modules/desktop.nix` (tuigreet) imports themes directly and uses rose-pine-moon — it doesn't participate in runtime switching since it runs before user login.

## Overlays and Custom Packages

Custom packages and nixpkgs modifications are organized in `/overlays/` and `/packages/`:

### Overlay Sets
The `overlays/default.nix` exports named sets for per-host selection:
- `overlays.all` — All overlays (NUR + xone + custom packages)
- `overlays.minimal` — Without gaming overlays (NUR + custom packages)
- `overlays.gaming` — Gaming-only (xone)

### Current Overlays
- **xone** (`overlays/xone.nix`): Builds the xone kernel module from nixpkgs-unstable against the current kernel (tracks latest version via the `nixpkgs-unstable` input)
- **custom-packages** (`overlays/custom-packages.nix`): Adds custom packages to pkgs namespace
- **nur**: NUR overlay (imported from flake input)

### Custom Packages (via `pkgs.*`)
- `pkgs.bricolage-grotesque` — Custom variable font
- `pkgs.qobuz-player` — TUI music player for Qobuz
- `pkgs.rose-pine-plymouth` — Plymouth boot splash theme

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
- **User secrets**: Defined in `users/flur/desktop/secrets.nix` (NextDNS URL, SSH hostname, Git signing key)

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
nh os switch  # No PIN required!
```

**Add new secrets**:
1. Create/encrypt file in nixos-secrets repo using age key
2. Add secret declaration to `modules/secrets.nix` (system) or `users/flur/desktop/secrets.nix` (user)
3. Reference secret in program config (see `users/flur/common/git.nix` or `zen-browser.nix` for patterns)

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
- `users/flur/common/git.nix` - Git signing key ID
- `users/flur/desktop/programs/zen-browser.nix` - NextDNS URL (uses activation-time substitution)

## Shell Aliases & Functions

Defined in `users/flur/desktop/shell/default.nix`:

- `nfc` — `nix flake check --no-build` (validate flake without building)
- `nf` — `nix fmt` (format Nix files using nixfmt-tree)
- `ivr` — `ivpn connect -f`

Rebuilds are done directly with `nh os switch` / `nh os test` (no aliases; see Build and Apply Commands).

**Zoxide** is initialized in fish (`zoxide init fish --cmd cd | source`), replacing `cd` with smart directory jumping.

## Tmuxinator Sessions

Declarative tmuxinator YAML configs are managed as `xdg.configFile` entries in `users/flur/desktop/shell/tmux.nix`:

| Session | Purpose | Windows |
|---------|---------|---------|
| `nixos`  | NixOS config development | nvim, claude, lazygit, scratch |
| `flur34` | Dioxus development | nvim+claude, devenv, lazygit, scratch |
| `netmon` | Network monitoring | bandwhich, iftop, nethogs |

**Sesh** (`<prefix>s`) provides interactive tmux session switching with fzf, showing all sessions, tmuxinator configs, and zoxide directories.

## Security Wrappers for Network Tools

Network monitoring tools are given elevated capabilities in `modules/base.nix` via `security.wrappers` rather than sudoers entries:

```nix
security.wrappers = {
  bandwhich = { capabilities = "cap_net_raw,cap_net_admin+eip"; ... };
  nethogs   = { capabilities = "cap_net_raw,cap_net_admin+eip"; ... };
  iftop     = { capabilities = "cap_net_raw+eip"; ... };
};
```

This allows running these tools without a password prompt.

## Important Notes

- **Theming**: Colors are defined in `modules/themes/default.nix` and consumed by `users/flur/desktop/wayland/themes.nix` which generates per-app theme files. Use `theme-switch [name]` to switch at runtime.
- **Hostname parameter**: Keep `hostname = "flurPC"` in extraSpecialArgs for Hyprland monitor configs
- **State version**: "25.11" for both system and home-manager (do not change)
- **Hardware config**: Do not edit `hardware-configuration.nix` manually - regenerate if needed
- **Terminal**: Foot — configured in `users/flur/desktop/shell/terminals.nix`
- **Home-manager backups**: Backup files use `.backup` extension (configured in flake.nix)
- **Flake structure**: Uses home-manager as a NixOS module, not standalone
- **Secrets repo**: Never commit unencrypted secrets; see `.gitignore` in nixos-secrets repo
- **Custom packages**: Use `pkgs.bricolage-grotesque`, `pkgs.qobuz-player`, `pkgs.rose-pine-plymouth` instead of callPackage
