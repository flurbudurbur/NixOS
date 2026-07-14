# NixOS Configuration

Personal flakes-based NixOS config, managed with [home-manager](https://github.com/nix-community/home-manager) and [nh](https://github.com/nix-community/nh).

## Hosts

- **flurPC**: desktop, Hyprland (Wayland), NVIDIA
- **vps**: headless netcup server; public relay hub + reverse proxy for homelab services
- **flurLab**: homelab PC; WireGuard spoke, runs Forgejo + SearXNG behind the vps proxy
- **installer**: minimal ISO for provisioning new machines

## Quick Commands

```bash
# Rebuild and switch (local host)
nh os switch

# Test without creating a boot entry
nh os test

# Update flake inputs and switch in one step
nh os switch --update

# Deploy to the VPS remotely
nixos-rebuild switch --flake .#vps --target-host root@<vps-ip> --build-host localhost

# Check flake for errors
nix flake check
```

## Secrets

Secrets live in a separate private repo (`nixos-secrets`, age-encrypted via sops-nix):

```bash
cd ~/nixos-secrets
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
sops secrets/user/nextdns.yaml   # or any other secret file

git add secrets/ && git commit -m "Update secrets" && git push
cd ~/nixos-system
nix flake lock --update-input nixos-secrets
nh os switch
```

## Structure

```
nixos-system/
├── flake.nix       # Inputs and nixosConfigurations (flurPC, vps, flurLab, installer)
├── overlays/       # Nixpkgs overlays (all / minimal / gaming)
├── packages/       # Custom package definitions
├── modules/        # Shared system modules (base, server, relay, desktop, gaming, ...)
├── hosts/          # Per-machine config (default.nix, hardware/disko, host-only services)
└── users/flur/     # Home-manager profiles (common/, desktop/, vps/)
```

## Notes

- State version: `25.11` (system and home-manager, do not change)
- Theming: multi-theme runtime switching via `theme-switch [name]` (rose-pine-moon, catppuccin-mocha, sweet)
- Hardware/disko files are generated, don't hand-edit
