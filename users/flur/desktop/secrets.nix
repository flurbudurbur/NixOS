{
  config,
  pkgs,
  secretsPath,
  ...
}:

{
  sops = {
    defaultSopsFormat = "yaml";

    # Use same age key as system (via symlink)
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    # Remove GPG configuration
    gnupg.sshKeyPaths = [ ];

    secrets = {
      "nextdns-url" = {
        sopsFile = "${secretsPath}/user/nextdns.yaml";
        path = "${config.xdg.configHome}/sops-secrets/nextdns-url";
        mode = "0400";
      };

      "ssh-shiori-hostname" = {
        sopsFile = "${secretsPath}/user/ssh-hosts.yaml";
        path = "${config.xdg.configHome}/sops-secrets/ssh-shiori-hostname";
        mode = "0400";
      };

      "ssh-flurlab-ip" = {
        sopsFile = "${secretsPath}/user/ssh-hosts.yaml";
        path = "${config.xdg.configHome}/sops-secrets/ssh-flurlab-ip";
        mode = "0400";
      };

      "git-signing-key" = {
        sopsFile = "${secretsPath}/user/git-signing.yaml";
        path = "${config.xdg.configHome}/sops-secrets/git-signing-key";
        mode = "0400";
      };
    };
  };

  # Add age package to user environment
  home.packages = with pkgs; [
    age
    sops
  ];
}
