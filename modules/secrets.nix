{ pkgs, ... }:

{
  sops = {
    defaultSopsFormat = "yaml";

    # Configure age key file for system secrets
    age.keyFile = "/root/.config/sops/age/keys.txt";

    # Remove GPG configuration
    gnupg.sshKeyPaths = [ ];

    validateSopsFiles = true;
    useSystemdActivation = true;

    secrets = { };
  };

  # Add age package for sops-nix
  environment.systemPackages = with pkgs; [
    age
    sops
  ];
}
