{
  config,
  lib,
  ...
}:

let
  sshHostnameFile = "${config.xdg.configHome}/sops-secrets/ssh-shiori-hostname";
in
{
  # Force overwrite to prevent backup file conflicts
  home.file.".ssh/config".force = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*".addKeysToAgent = "yes";

      # GitHub authentication using FIDO2 resident keys on Yubikeys
      # Falls back to regular key if Yubikeys aren't available
      "github.com" = {
        identitiesOnly = true;
        identityFile = [
          "~/.ssh/id_ed25519_sk_rk_aloha" # Backup Yubikey (Aloha)
          "~/.ssh/id_ed25519_sk_rk_pink" # Primary Yubikey (Pink)
          "~/.ssh/github" # Fallback non-hardware key
        ];
      };

      "shiori" = {
        hostname = "@SHIORI_HOSTNAME@";
        user = "flur";
        identityFile = [ "~/.ssh/shiori" ];
      };
    };
  };

  # Substitute secret hostname into SSH config after sops-nix decrypts it
  home.activation.substituteShioriHostname = lib.hm.dag.entryAfter [ "sops-nix" ] ''
    if [ -f "${sshHostnameFile}" ]; then
      HOSTNAME=$(tr -d '\n' < "${sshHostnameFile}")
      sed -i "s|@SHIORI_HOSTNAME@|$HOSTNAME|g" ~/.ssh/config
    else
      echo "Warning: ${sshHostnameFile} not found, skipping hostname substitution"
    fi
  '';
}
