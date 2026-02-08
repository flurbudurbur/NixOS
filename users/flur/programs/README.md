# GPG + Yubikey Setup Guide

This guide walks you through setting up GPG with your Yubikey for git commit signing, file encryption, and email encryption.

## Prerequisites

✅ Configuration applied with `nixos-rebuild`
✅ Yubikey detected: Run `ykman list` to verify
✅ GPG can see card: Run `gpg --card-status` to verify

## Step 1: Change Default PINs

The Yubikey ships with default PINs that must be changed:
- **Default User PIN**: 123456
- **Default Admin PIN**: 12345678

### Change PINs:

```bash
gpg --card-edit
```

At the `gpg/card>` prompt:
```
admin
passwd
```

You'll see a menu:
- **1** = Change PIN (user PIN - you'll enter this frequently)
- **3** = Change Admin PIN (for administrative operations)

Change both PINs, then:
```
quit
```

### PIN Recommendations:
- **User PIN**: 6-8 digits (easy to type, you'll use it often)
- **Admin PIN**: 8+ characters (store in password manager)
- Write down your PINs and store securely!

## Step 2: Generate GPG Keys on Yubikey

Generate keys directly on the Yubikey (most secure - keys never leave hardware):

```bash
gpg --card-edit --expert
```

At the `gpg/card>` prompt:
```
admin
generate
```

### Answer the prompts:

1. **Make off-card backup?** → `n` (NO)
   - Keys stay only on Yubikey for maximum security
   - If you need a backup, buy a second Yubikey

2. **Key validity** → `2y`
   - Keys expire in 2 years (recommended security practice)
   - You can extend expiration later

3. **Real name** → `flurbudurbur`
   - Must match your git config

4. **Email address** → `69259138+flurbudurbur@users.noreply.github.com`
   - Must match your git config

5. **Comment** → (press Enter to skip, or type "Yubikey")

6. **Confirm** → `O` (capital O for Okay)

The Yubikey will generate three keys:
- **Signature key** (for signing commits/files)
- **Encryption key** (for encrypting files)
- **Authentication key** (for SSH if needed)

When done, type:
```
quit
```

## Step 3: Enable Touch Requirement

Require physical touch of Yubikey for every GPG operation (recommended):

```bash
# Require touch for signing (git commits)
ykman openpgp keys set-touch sig on

# Require touch for encryption/decryption
ykman openpgp keys set-touch enc on

# Require touch for authentication
ykman openpgp keys set-touch aut on
```

### Touch Policy Options:
- `on` - Touch required every time (most secure)
- `off` - No touch required (less secure)
- `cached` - Touch required once per session (balance)
- `fixed` - Touch required, cannot be changed without reset

**Recommendation**: Start with `on`. Change to `cached` later if it becomes inconvenient.

## Step 4: Get Your Key Fingerprint

```bash
gpg --card-status
```

Look for the line starting with **"Signature key"** - this shows your key fingerprint.

Or use:
```bash
gpg --list-secret-keys --keyid-format=long
```

Copy the **40-character hex fingerprint** (example: `1234567890ABCDEF1234567890ABCDEF12345678`)

## Step 5: Update Git Configuration

Edit `home/programs/git.nix` and add your key fingerprint:

```nix
programs.git = {
  enable = true;
  settings = {
    user.name = "flurbudurbur";
    user.email = "69259138+flurbudurbur@users.noreply.github.com";
    user.signingkey = "YOUR_40_CHAR_FINGERPRINT_HERE";  # ADD THIS LINE
    init.defaultBranch = "main";

    commit.gpgsign = true;
    gpg.program = "${pkgs.gnupg}/bin/gpg";
  };
};
```

Then rebuild:
```bash
cd /home/flur/nixos-system
git add home/programs/git.nix
nixos-rebuild test --sudo --flake .
```

## Step 6: Test Git Commit Signing

```bash
cd /tmp
git init test-yubikey-signing
cd test-yubikey-signing

# Configure git for this test repo
git config user.name "flurbudurbur"
git config user.email "69259138+flurbudurbur@users.noreply.github.com"

# Make a test commit
git commit --allow-empty -m "Test Yubikey GPG signing"
```

**What should happen:**
1. Pinentry GUI appears asking for your User PIN
2. Yubikey LED blinks (waiting for touch)
3. Touch the Yubikey
4. Commit succeeds

Verify the signature:
```bash
git log --show-signature -1
```

You should see:
```
gpg: Signature made ...
gpg: Good signature from "flurbudurbur <69259138+flurbudurbur@users.noreply.github.com>"
```

## Step 7: Export Public Key for GitHub/GitLab

Export your public key:
```bash
gpg --armor --export 69259138+flurbudurbur@users.noreply.github.com > ~/yubikey-gpg-public.asc
cat ~/yubikey-gpg-public.asc
```

Copy the entire output (from `-----BEGIN PGP PUBLIC KEY BLOCK-----` to `-----END PGP PUBLIC KEY BLOCK-----`)

### Add to GitHub:
1. Go to: https://github.com/settings/keys
2. Click "New GPG key"
3. Paste your public key
4. Click "Add GPG key"

### Add to GitLab:
1. Go to: https://gitlab.com/-/user_settings/gpg_keys
2. Click "Add new key"
3. Paste your public key
4. Click "Add key"

## Step 8: Test File Encryption

```bash
# Create a test file
echo "Secret data" > /tmp/test.txt

# Encrypt to yourself
gpg --encrypt --recipient 69259138+flurbudurbur@users.noreply.github.com /tmp/test.txt

# This creates test.txt.gpg
# You'll need to enter PIN and touch Yubikey

# Decrypt
gpg --decrypt /tmp/test.txt.gpg

# Should output: "Secret data"
```

## Backup Strategy

Your private keys are ONLY on the Yubikey. If you lose it, the keys are gone forever.

### Option 1: No Backup (Most Secure)
- Keys only on Yubikey
- If lost: Generate new keys, revoke old ones
- GitHub allows multiple GPG keys

### Option 2: Backup Yubikey
- Buy a second Yubikey
- Generate keys on computer first
- Move copies to both Yubikeys
- Store backup Yubikey in safe location

### Option 3: Encrypted Backup
- Export private key: `gpg --armor --export-secret-keys > backup.asc`
- Encrypt backup: `gpg --symmetric --cipher-algo AES256 backup.asc`
- Store encrypted `backup.asc.gpg` on external drive
- Delete unencrypted version: `shred -u backup.asc`

**Recommendation**: Start with Option 1. You can always generate new keys if needed.

### What to Backup:
```bash
# Backup public key
cp ~/yubikey-gpg-public.asc /path/to/backup/

# Backup revocation certificate (auto-generated)
cp ~/.gnupg/openpgp-revocs.d/*.rev /path/to/backup/
```

## Daily Usage

### Signing Commits:
```bash
git commit -m "Your message"
# Enter PIN when prompted
# Touch Yubikey when LED blinks
```

### If PIN is cached, you only need to touch the Yubikey for each operation.

### Encrypt a File:
```bash
gpg --encrypt --recipient YOUR_EMAIL file.txt
```

### Decrypt a File:
```bash
gpg --decrypt file.txt.gpg > file.txt
```

### Check Yubikey Status:
```bash
gpg --card-status
```

### Check Your Keys:
```bash
gpg --list-secret-keys
```

## Troubleshooting

### Yubikey Not Detected

```bash
# Restart PC/SC daemon
sudo systemctl restart pcscd

# Check detection
ykman list
gpg --card-status
```

### "No such device" Error

```bash
# Restart smartcard daemon
gpgconf --kill scdaemon
gpgconf --launch scdaemon
```

### Pinentry Doesn't Appear

```bash
# Check GPG agent
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent

# Test pinentry
echo "GETPIN" | pinentry-gnome3
```

### Git Signing Fails

```bash
# Verify card works
gpg --card-status

# Test signing directly
echo "test" | gpg --clearsign

# Check git config
git config --global user.signingkey
```

### Touch Not Working

```bash
# Check touch settings
ykman openpgp info

# Re-enable touch
ykman openpgp keys set-touch sig on
```

### Wrong PIN / PIN Locked

```bash
# Check PIN retry counter
gpg --card-status
# Look for "PIN retry counter"

# If locked, unblock with admin PIN
gpg --card-edit
> admin
> passwd
> 2  (unblock PIN)
> quit
```

**If admin PIN is also locked:**
```bash
# Factory reset (ERASES ALL KEYS!)
ykman openpgp reset
# Then start over from Step 1
```

## Key Expiration

Keys expire after 2 years (or your chosen period). To extend:

```bash
gpg --card-edit
> admin
> key-attr
# Follow prompts to extend expiration
> quit
```

Or extend from your key backup if you made one.

## Advanced: SSH with Yubikey (Optional)

If you want to use Yubikey for SSH authentication (in addition to GNOME Keyring):

1. Edit `home/programs/gpg.nix`:
```nix
services.gpg-agent.enableSshSupport = true;
```

2. Rebuild system

3. Export SSH public key:
```bash
gpg --export-ssh-key 69259138+flurbudurbur@users.noreply.github.com > ~/.ssh/yubikey.pub
```

4. Add to GitHub/servers as SSH key

**Note**: This replaces GNOME Keyring for SSH. Current setup keeps them separate.

## Security Benefits

✅ **Private keys never leave hardware** - Safe even if computer is compromised
✅ **Physical presence required** - Attacker needs physical access to Yubikey
✅ **PIN protection** - Additional layer even with physical access
✅ **Tamper-resistant** - Yubikey designed to resist key extraction
✅ **Verified commits** - GitHub shows "Verified" badge on signed commits

## References

- Full setup plan: `/home/flur/.claude/plans/twinkly-moseying-crab.md`
- Yubikey GPG Guide: https://github.com/drduh/YubiKey-Guide
- GnuPG Documentation: https://gnupg.org/documentation/
- Home-manager GPG options: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.gpg.enable

## Configuration Files

- GPG config: `home/programs/gpg.nix`
- Git config: `home/programs/git.nix`
- System smartcard support: `modules/system.nix`
