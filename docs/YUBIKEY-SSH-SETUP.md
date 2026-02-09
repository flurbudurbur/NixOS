# Yubikey SSH Setup with FIDO2 Resident Keys

This guide covers setting up SSH authentication using FIDO2 resident keys stored on your Yubikeys for cloning private GitHub repositories.

## Overview

**What are FIDO2 Resident Keys?**
- SSH keys stored directly on your Yubikey's secure hardware
- Can be extracted on any machine with just the Yubikey plugged in
- Requires physical touch to authenticate (phishing-resistant)
- Works with OpenSSH 8.2+ (included in NixOS 25.11)
- You have 2 Yubikeys for redundancy: **Pink** (primary) and **Aloha** (backup)

**Configuration Location**: `users/flur/programs/git.nix`

## Initial Setup (One-Time)

### Step 1: Generate FIDO2 Keys on Both Yubikeys

**Insert Yubikey "Pink" (primary)** and run:
```bash
# Generate resident key on Pink
ssh-keygen -t ed25519-sk -O resident -O application=ssh:github-pink -C "flur@pink-github" -f ~/.ssh/id_ed25519_sk_rk_pink

# When prompted:
# - Enter PIN for authenticator (your Yubikey's FIDO2/Admin PIN if set)
# - Touch your Yubikey when it blinks (may need to touch twice)
# - Enter SSH key passphrase (optional but recommended)
```

**Remove Pink, insert Yubikey "Aloha" (backup)** and run:
```bash
# Generate resident key on Aloha
ssh-keygen -t ed25519-sk -O resident -O application=ssh:github-aloha -C "flur@aloha-github" -f ~/.ssh/id_ed25519_sk_rk_aloha

# When prompted:
# - Enter PIN for authenticator (your Yubikey's FIDO2/Admin PIN if set)
# - Touch your Yubikey when it blinks (may need to touch twice)
# - Enter SSH key passphrase (optional but recommended)
```

**Troubleshooting Key Generation:**

If you get "Key enrollment failed: invalid format":
```bash
# Check FIDO2 capabilities
ykman fido info

# Try without application flag (simpler)
ssh-keygen -t ed25519-sk -O resident -C "flur@pink-github" -f ~/.ssh/id_ed25519_sk_rk_pink

# If FIDO2 PIN not set, set one:
ykman fido access change-pin
```

### Step 2: Upload Public Keys to GitHub

```bash
# Display public keys
cat ~/.ssh/id_ed25519_sk_rk_pink.pub
cat ~/.ssh/id_ed25519_sk_rk_aloha.pub
```

1. Go to https://github.com/settings/keys
2. Click "New SSH key"
3. Add **both** public keys:
   - Title: "Yubikey Pink - FIDO2 Resident Key"
   - Key: Paste contents of `id_ed25519_sk_rk_pink.pub`
   - Click "Add SSH key"
4. Repeat for Yubikey Aloha

### Step 3: Test Authentication

**With Yubikey Pink plugged in:**
```bash
ssh -T git@github.com
# Should prompt: "Touch your authenticator device now..."
# Touch Yubikey, expect: "Hi flurbudurbur! You've successfully authenticated..."
```

**With Yubikey Aloha plugged in:**
```bash
ssh -T git@github.com
# Test with backup Yubikey (should also work)
```

## Fresh Install Recovery

This is the key workflow for cloning repos on a fresh NixOS install:

### Recovery Steps

1. **Boot fresh NixOS install**

2. **Insert either Yubikey** (Pink or Aloha - whichever is available)

3. **Extract resident keys from Yubikey:**
```bash
# Create SSH directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Download resident keys from Yubikey
# This will prompt for PIN and require touch
ssh-keygen -K

# This creates files in current directory:
# - id_ed25519_sk_rk_<random>
# - id_ed25519_sk_rk_<random>.pub

# Move to proper location
mv id_ed25519_sk_rk_* ~/.ssh/
```

4. **Rename extracted keys to match config:**
```bash
# Find which Yubikey you're using by checking the comment in .pub file
cat ~/.ssh/id_ed25519_sk_rk_*.pub
# Look for "flur@pink-github" or "flur@aloha-github"

# Rename accordingly:
# If Pink:
mv ~/.ssh/id_ed25519_sk_rk_* ~/.ssh/id_ed25519_sk_rk_pink
mv ~/.ssh/id_ed25519_sk_rk_*.pub ~/.ssh/id_ed25519_sk_rk_pink.pub

# If Aloha:
mv ~/.ssh/id_ed25519_sk_rk_* ~/.ssh/id_ed25519_sk_rk_aloha
mv ~/.ssh/id_ed25519_sk_rk_*.pub ~/.ssh/id_ed25519_sk_rk_aloha.pub

# Set proper permissions
chmod 600 ~/.ssh/id_ed25519_sk_rk_*
chmod 644 ~/.ssh/id_ed25519_sk_rk_*.pub
```

5. **Clone your private repositories:**
```bash
# Clone nixos-secrets (uses Yubikey for auth)
git clone git@github.com:flurbudurbur/nix-secrets.git ~/nixos-secrets

# Clone main config
git clone git@github.com:flurbudurbur/nixos-system.git ~/nixos-system

# Touch Yubikey when prompted during git operations
```

6. **Rebuild system** (this will generate the full SSH config from git.nix):
```bash
cd ~/nixos-system
sudo nixos-rebuild switch --flake .#flurPC
```

7. **Extract second Yubikey's key** (optional, for full redundancy):
```bash
# Remove first Yubikey, insert second
# Repeat ssh-keygen -K process for the other key
```

## How It Works

**SSH Config** (`users/flur/programs/git.nix:30-42`):
```nix
"github.com" = {
  identitiesOnly = true;
  identityFile = [
    "~/.ssh/id_ed25519_sk_rk_pink"   # Primary Yubikey (Pink)
    "~/.ssh/id_ed25519_sk_rk_aloha"  # Backup Yubikey (Aloha)
    "~/.ssh/github"                  # Fallback non-hardware key
  ];
};
```

**Authentication Flow**:
1. SSH tries first identity file (Pink)
2. If not found or Yubikey not plugged in, tries Aloha
3. If neither hardware key works, falls back to regular `~/.ssh/github`
4. When hardware key is used, Yubikey blinks → you touch it → authentication succeeds

**Key Storage**:
- **Private key stub**: `~/.ssh/id_ed25519_sk_rk_pink` (small file, points to Yubikey)
- **Public key**: `~/.ssh/id_ed25519_sk_rk_pink.pub` (can be shared)
- **Actual secret**: Stored in Yubikey hardware (never leaves device)

## Troubleshooting

**"sign_and_send_pubkey: signing failed for ED25519-SK"**
- Yubikey not plugged in → Insert Yubikey
- Didn't touch when prompted → Try again and touch Yubikey
- Wrong key extracted → Check the comment in .pub file matches config

**"Permission denied (publickey)"**
- Public key not added to GitHub → Go to https://github.com/settings/keys
- Wrong identity file name → Check `~/.ssh/` matches git.nix config
- Test with: `ssh -vvv -T git@github.com` to see which keys are being tried

**"ssh-keygen -K" finds no keys**
- No resident keys on this Yubikey → Use the other Yubikey
- Keys generated without `-O resident` → Regenerate with resident flag
- Application name mismatch → Check with `ykman fido credentials list`

**"Key enrollment failed: invalid format"**
- Wrong PIN entered → Check your Yubikey FIDO2 PIN
- FIDO2 not enabled → Run `ykman fido info` to check capabilities
- Try without `-O application` flag → Simpler command may work better

**Lost both Yubikeys**
- Use fallback key at `~/.ssh/github` (if you have it backed up)
- Regenerate new FIDO2 keys on replacement Yubikeys
- This is why we have the fallback in the config!

## Key Management Commands

```bash
# List resident credentials on Yubikey
ykman fido credentials list

# Check FIDO2 info and PIN status
ykman fido info

# Set/change FIDO2 PIN
ykman fido access change-pin

# Delete a resident credential (DESTRUCTIVE!)
ykman fido credentials delete ssh:github-pink     # For Pink
ykman fido credentials delete ssh:github-aloha    # For Aloha

# Re-extract keys from Yubikey (non-destructive)
ssh-keygen -K

# Test which Yubikey is plugged in
ssh-keygen -K  # Check comment in generated .pub file for "pink" or "aloha"

# Verify public key is on GitHub
curl -s https://github.com/flurbudurbur.keys | grep -f ~/.ssh/id_ed25519_sk_rk_pink.pub
curl -s https://github.com/flurbudurbur.keys | grep -f ~/.ssh/id_ed25519_sk_rk_aloha.pub
```

## Security Notes

**Benefits**:
- Private keys never leave the Yubikey (can't be stolen via malware)
- Requires physical device + touch (phishing-resistant)
- Works on fresh installs without key backups
- Two Yubikeys = redundancy if one is lost

**Considerations**:
- Lose both Yubikeys = lose hardware auth (fallback key required)
- Yubikey must be physically present for git operations
- Touch required for each SSH connection (can be annoying during frequent pulls/pushes)
- FIDO2 PIN protects against unauthorized key extraction

**Backup Strategy**:
- Keep both Yubikeys in separate locations
- Maintain fallback `~/.ssh/github` key (encrypted backup recommended)
- Public keys backed up in this repo's documentation
- Remember your FIDO2 PIN (or document it securely)

## References

- OpenSSH FIDO/U2F: https://www.openssh.com/txt/release-8.2
- Yubikey FIDO2: https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html
- GitHub SSH Keys: https://docs.github.com/en/authentication/connecting-to-github-with-ssh
