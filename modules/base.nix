{ pkgs, ... }:
{
  # Nix settings
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [ "https://devenv.cachix.org" ];
    extra-trusted-public-keys = [ "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" ];
  };
  nixpkgs.config.allowUnfree = true;

  # Auto-optimize store (deduplicate files)
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "weekly" ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # User accounts
  users.users.flur = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "input"
      "podman"
    ];
    shell = pkgs.fish;
  };
  environment.shells = with pkgs; [ fish ];

  # Locale
  time.timeZone = "Europe/Amsterdam";

  # System packages (basic tools)
  environment.systemPackages = with pkgs; [
    git
    pciutils
    usbutils
    tree
    wget
    btop
    bat
  ];

  programs.fish.enable = true;

  # Enable nix-ld for dynamically linked binaries (fnm/node, etc.)
  programs.nix-ld.enable = true;

  # Grant network capture capabilities to monitoring tools (avoids sudo)
  security.wrappers = {
    bandwhich = {
      owner = "root";
      group = "root";
      capabilities = "cap_net_raw,cap_net_admin+eip";
      source = "${pkgs.bandwhich}/bin/bandwhich";
    };
    nethogs = {
      owner = "root";
      group = "root";
      capabilities = "cap_net_raw,cap_net_admin+eip";
      source = "${pkgs.nethogs}/bin/nethogs";
    };
    iftop = {
      owner = "root";
      group = "root";
      capabilities = "cap_net_raw+eip";
      source = "${pkgs.iftop}/bin/iftop";
    };
  };
}
