{ pkgs, secretsPath, ... }:

{
  sops = {
    defaultSopsFormat = "yaml";

    # Configure age key file for system secrets
    age.keyFile = "/root/.config/sops/age/keys.txt";

    # Remove GPG configuration
    gnupg.sshKeyPaths = [ ];

    validateSopsFiles = true;

    secrets = {
      # Re-enable Mullvad VPN secrets now that age works non-interactively
      "mullvad-account-history" = {
        sopsFile = "${secretsPath}/system/mullvad/account-history.enc";
        format = "binary";
        path = "/etc/mullvad-vpn/account-history.json";
        owner = "root";
        group = "root";
        mode = "0600";
        restartUnits = [ "mullvad-daemon.service" ];
      };

      "mullvad-device" = {
        sopsFile = "${secretsPath}/system/mullvad/device.enc";
        format = "binary";
        path = "/etc/mullvad-vpn/device.json";
        owner = "root";
        group = "root";
        mode = "0600";
        restartUnits = [ "mullvad-daemon.service" ];
      };

      "mullvad-settings" = {
        sopsFile = "${secretsPath}/system/mullvad/settings.enc";
        format = "binary";
        path = "/etc/mullvad-vpn/settings.json";
        owner = "root";
        group = "root";
        mode = "0644";
        restartUnits = [ "mullvad-daemon.service" ];
      };
    };
  };

  # Add age package for sops-nix
  environment.systemPackages = with pkgs; [
    age
    sops
  ];
}
