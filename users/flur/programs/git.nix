{ pkgs, config, lib, ... }:

let
  signingKeyFile = "${config.xdg.configHome}/sops-secrets/git-signing-key";

  signingKey = if builtins.pathExists signingKeyFile
    then lib.removeSuffix "\n" (lib.fileContents signingKeyFile)
    else "59327CBED7938BDBE74B167D57CF006A8AD85F44";

  sshHostnameFile = "${config.xdg.configHome}/sops-secrets/ssh-shiori-hostname";
in
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "flurbudurbur";
      user.email = "69259138+flurbudurbur@users.noreply.github.com";
      user.signingkey = signingKey;
      init.defaultBranch = "main";

      # GPG signing configuration
      commit.gpgsign = true;
      gpg.program = "${pkgs.gnupg}/bin/gpg";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    # shiori host is written at activation time (see home.activation below)
    # so that the hostname secret is read after sops-nix decrypts it
    extraConfig = "Include ~/.ssh/shiori_config";
    matchBlocks = {
      "*".addKeysToAgent = "yes";

      # GitHub authentication using FIDO2 resident keys on Yubikeys
      # Falls back to regular key if Yubikeys aren't available
      "github.com" = {
        identitiesOnly = true;
        identityFile = [
          "~/.ssh/id_ed25519_sk_rk_pink"   # Primary Yubikey (Pink)
          "~/.ssh/id_ed25519_sk_rk_aloha"  # Backup Yubikey (Aloha)
          "~/.ssh/github"                  # Fallback non-hardware key
        ];
      };
    };
  };

  # Write shiori SSH config at activation time so the secret hostname is
  # read after sops-nix has decrypted it, not at Nix evaluation time.
  home.activation.generateSshShioriConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    HOSTNAME=$(cat "${sshHostnameFile}" 2>/dev/null | tr -d '\n')
    HOSTNAME=''${HOSTNAME:-console.flur.dev}
    printf 'Host shiori\n  IdentityFile ~/.ssh/shiori\n  User flur\n  Hostname %s\n' "$HOSTNAME" > ~/.ssh/shiori_config
    chmod 600 ~/.ssh/shiori_config
  '';
}
