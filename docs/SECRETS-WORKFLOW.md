# Secrets Workflow

This guide covers the end-to-end workflow for managing secrets in this NixOS configuration using sops-nix with age encryption.

## Architecture Overview

Secrets live in a **separate private repository** (`git@github.com:flurbudurbur/nix-secrets.git`), referenced as the `nixos-secrets` flake input. The main NixOS config never contains plaintext secrets -- it only references paths into the secrets repo via the `secretsPath` parameter that the flake passes through `specialArgs` and `extraSpecialArgs`.

There are two layers of secrets:

| Layer | Config file | age key location | Decrypted to | Owner |
|-------|-------------|------------------|-------------|-------|
| System | `modules/secrets.nix` | `/root/.config/sops/age/keys.txt` | Paths under `/etc/` | root |
| User | `users/flur/secrets.nix` | `~/.config/sops/age/keys.txt` | `~/.config/sops-secrets/` | flur |

Both use the same age keypair (the user copy is a symlink or copy of the root key). The public key is `age1cnnmaf766jhumy92hqtgrxyr8z8vjymrj05j2k6hap57g3c50gmq2uhm36`.

## Current Secrets

### System secrets (modules/secrets.nix)

All Mullvad VPN configuration, decrypted as binary format:

- `mullvad-account-history` -> `/etc/mullvad-vpn/account-history.json`
- `mullvad-device` -> `/etc/mullvad-vpn/device.json`
- `mullvad-settings` -> `/etc/mullvad-vpn/settings.json`

These use `restartUnits` to restart `mullvad-daemon.service` when secrets change. System secrets use `useSystemdActivation = true` so they are decrypted via a systemd unit during boot.

### User secrets (users/flur/secrets.nix)

- `nextdns-url` -> `~/.config/sops-secrets/nextdns-url` (NextDNS DoH endpoint for Zen Browser)
- `ssh-shiori-hostname` -> `~/.config/sops-secrets/ssh-shiori-hostname` (SSH host for Shiori)
- `git-signing-key` -> `~/.config/sops-secrets/git-signing-key` (GPG key ID for commit signing)

User secrets are decrypted by the home-manager sops module during activation.

## Cross-Repo Workflow

### Editing an existing secret

```bash
# 1. Go to the secrets repo
cd /home/flur/nixos-secrets

# 2. Set the age key for sops
export SOPS_AGE_KEY_FILE=/home/flur/.config/sops/age/keys.txt

# 3. Edit the secret (sops decrypts in-place for editing, re-encrypts on save)
sops secrets/user/nextdns.yaml      # YAML secrets
sops secrets/system/mullvad/settings.enc  # Binary secrets

# 4. Commit and push
git add secrets/
git commit -m "Update secret"
git push

# 5. Back in the main config, update the flake input to pull the new commit
cd /home/flur/nixos-system
nix flake lock --update-input nixos-secrets

# 6. Rebuild
sudo nixos-rebuild switch --flake .#flurPC
```

### Adding a new secret

1. Create and encrypt the secret file in the nixos-secrets repo:

```bash
cd /home/flur/nixos-secrets
export SOPS_AGE_KEY_FILE=/home/flur/.config/sops/age/keys.txt

# For YAML secrets (most common for user secrets)
sops secrets/user/my-new-secret.yaml
# Editor opens -- add key-value pairs, save, sops encrypts automatically

# For binary secrets (opaque files like JSON configs)
sops -e --input-type binary secrets/system/service/config.enc < plaintext-file.json
```

2. Declare the secret in the appropriate config file:

For **system secrets** -- add to `modules/secrets.nix`:

```nix
"my-secret" = {
  sopsFile = "${secretsPath}/system/service/config.enc";
  format = "binary";  # or "yaml"
  path = "/etc/my-service/config.json";
  owner = "root";
  group = "root";
  mode = "0600";
  restartUnits = [ "my-service.service" ];  # optional
};
```

For **user secrets** -- add to `users/flur/secrets.nix`:

```nix
"my-secret" = {
  sopsFile = "${secretsPath}/user/my-new-secret.yaml";
  path = "${config.xdg.configHome}/sops-secrets/my-secret";
  mode = "0400";
};
```

3. Use the secret in a program module (see substitution patterns below).

4. Push the secrets repo, update the flake input, and rebuild.

## Secret Substitution Patterns

There are two patterns for consuming decrypted secrets in module configuration. Which one to use depends on when the secret value is needed.

### Pattern 1: Evaluation-time (builtins.pathExists)

Used in: `users/flur/programs/git.nix`

```nix
let
  secretFile = "${config.xdg.configHome}/sops-secrets/git-signing-key";
  signingKey =
    if builtins.pathExists secretFile then
      lib.removeSuffix "\n" (lib.fileContents secretFile)
    else
      "59327CBED7938BDBE74B167D57CF006A8AD85F44";  # fallback
in
{
  programs.git.settings.user.signingkey = signingKey;
}
```

**How it works**: During `nix eval` (part of `nixos-rebuild`), Nix reads the decrypted secret file and bakes its contents directly into the generated configuration. The `builtins.pathExists` guard provides a fallback for initial builds where secrets haven't been decrypted yet.

**When to use**: When the secret value needs to appear literally in a generated config file (e.g., a git config setting). The value becomes part of the Nix store, so this is appropriate for non-sensitive identifiers (like a public key ID) but not for actual credentials.

**Trade-off**: The value is embedded in the Nix store derivation. Anyone with store access can read it. Use only for values that are identifying but not themselves secret (key IDs, hostnames).

### Pattern 2: Activation-time (template + sed)

Used in: `users/flur/programs/zen-browser.nix`

```nix
# In the config, use a placeholder
DNSOverHTTPS = {
  ProviderURL = "@NEXTDNS_URL@";
};

# In activation, substitute the real value
home.activation.substituteZenBrowserSecrets =
  lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f "${config.xdg.configHome}/sops-secrets/nextdns-url" ]; then
      NEXTDNS_URL=$(cat "${config.xdg.configHome}/sops-secrets/nextdns-url")
      POLICIES_DIR="$HOME/.zen"
      if [ -d "$POLICIES_DIR" ]; then
        find "$POLICIES_DIR" -type f \( -name "*.js" -o -name "*.json" \) \
          | while read file; do
              sed -i "s|@NEXTDNS_URL@|$NEXTDNS_URL|g" "$file" 2>/dev/null || true
            done
      fi
    fi
  '';
```

**How it works**: The Nix-generated config contains a literal placeholder (`@NEXTDNS_URL@`). After home-manager writes all files (`writeBoundary`), an activation script reads the decrypted secret and substitutes it into the generated files in-place.

**When to use**: When the secret is an actual credential (API key, URL with embedded token) that should not appear in the Nix store. The substitution happens at activation time in the user's home directory, so the secret only exists in the final config file, not in `/nix/store/`.

**Trade-off**: More complex. The activation script runs after every `home-manager switch`, and you need to handle the case where the secret file doesn't exist yet. The placeholder also means `nix flake check` won't catch an invalid URL format.

### Decision guide

| Criterion | Pattern 1 (eval-time) | Pattern 2 (activation-time) |
|-----------|----------------------|---------------------------|
| Value is sensitive | No | Yes |
| Needs Nix store privacy | No | Yes |
| Needs fallback for first build | Yes (use `if pathExists`) | Yes (use `if [ -f ... ]`) |
| Config format supports it | Nix-native options | Any file (sed works on anything) |
| Complexity | Low | Medium |

## sops-nix Integration

### NixOS module (system-level)

Imported in `flake.nix` as `sops-nix.nixosModules.sops`. Configuration lives in `modules/secrets.nix`. Key settings:

- `sops.age.keyFile` = `/root/.config/sops/age/keys.txt`
- `sops.useSystemdActivation = true` -- secrets are decrypted by a systemd unit
- `sops.validateSopsFiles = true` -- validates encrypted files during build
- `sops.gnupg.sshKeyPaths = []` -- explicitly disables GPG (age only)

### Home-manager module (user-level)

Imported in `flake.nix` as a shared module: `sops-nix.homeManagerModules.sops`. Configuration lives in `users/flur/secrets.nix`. Key settings:

- `sops.age.keyFile` = `~/.config/sops/age/keys.txt`
- `sops.gnupg.sshKeyPaths = []` -- explicitly disables GPG

The `secretsPath` parameter is passed from the flake through both `specialArgs` (for system modules) and `extraSpecialArgs` (for home-manager modules), pointing to the secrets directory in the `nixos-secrets` flake input.

## GPG to age Migration

### History

Before 2026-01-19, secrets were encrypted with GPG key `59327CBED7938BDBE74B167D57CF006A8AD85F44` stored on a Yubikey.

### Why the migration happened

GPG + Yubikey requires interactive PIN entry. This works fine in a terminal but fails when sops-nix tries to decrypt secrets during `nixos-rebuild` in a systemd activation context -- there is no TTY available for the PIN prompt. This caused Mullvad VPN secrets (and any system-level secret) to fail silently during boot.

### Current state

- **Secret decryption**: age (non-interactive, no hardware token needed)
- **Git commit signing**: Still uses GPG + Yubikey (interactive context, PIN prompt works)
- GPG and Yubikey packages remain installed (`users/flur/programs/gpg.nix`) for commit signing
- Both `modules/secrets.nix` and `users/flur/secrets.nix` explicitly set `gnupg.sshKeyPaths = []` to prevent sops-nix from trying to use GPG

## age Key Management

### Key locations

- **Root key**: `/root/.config/sops/age/keys.txt` -- used by system-level sops during boot
- **User key**: `/home/flur/.config/sops/age/keys.txt` -- used by home-manager sops during activation

### Generating a new key

```bash
age-keygen -o keys.txt
# Public key is printed to stdout -- record it for .sops.yaml in the secrets repo
```

### Rotating keys

If you need to rotate the age key:

1. Generate a new keypair
2. Update `.sops.yaml` in the nixos-secrets repo with the new public key
3. Re-encrypt all secrets: `sops updatekeys secrets/path/to/file.yaml`
4. Deploy the new private key to both `/root/.config/sops/age/keys.txt` and `~/.config/sops/age/keys.txt`
5. Rebuild

## Debugging

### Secret not available after rebuild

1. Check the age key exists:
   ```bash
   ls -la /root/.config/sops/age/keys.txt       # system
   ls -la ~/.config/sops/age/keys.txt            # user
   ```

2. Check the decrypted secret exists at its target path:
   ```bash
   ls -la /etc/mullvad-vpn/                      # system secrets
   ls -la ~/.config/sops-secrets/                 # user secrets
   ```

3. Try decrypting manually:
   ```bash
   export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
   sops -d /path/to/encrypted/file.yaml
   ```

4. Check the sops-nix systemd unit (system secrets):
   ```bash
   systemctl status sops-nix
   journalctl -u sops-nix
   ```

### Common failure modes

- **"key not found" during rebuild**: The age private key is missing or has wrong permissions. Must be readable by root (system) or the user (home-manager).
- **Secret file exists but is empty**: The sops file format doesn't match `format` in the declaration (e.g., declaring `format = "yaml"` for a binary-encrypted file).
- **Activation-time substitution not working**: The `home.activation` script runs before sops-nix decrypts secrets if ordering is wrong. Use `lib.hm.dag.entryAfter ["writeBoundary"]` and verify the sops secret path exists in the activation script.
- **Stale secret after updating nixos-secrets**: You must run `nix flake lock --update-input nixos-secrets` to update the flake lockfile. Without this, the build still references the old commit of the secrets repo.
- **Eval-time pattern returns fallback**: `builtins.pathExists` checks at evaluation time. If the secret was just added, you may need two rebuilds: the first deploys the sops secret, the second picks it up via `pathExists`.
