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

  # User accounts
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  users.users.flur = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "input"
      "podman"
    ];
    shell = pkgs.zsh;
  };
  environment.shells = with pkgs; [ zsh ];

  # Fonts
  fonts.packages = with pkgs; [
    bricolage-grotesque
  ];
  fonts.fontconfig.defaultFonts.monospace = [ "Maple Mono" ];

  # Services
  services = {
    flatpak.enable = true;
    pulseaudio.enable = false;
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    gnome.gnome-online-accounts.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      extraConfig.pipewire."92-high-res-audio" = {
        "context.properties" = {
          "default.clock.rate" = 96000;
          "default.clock.allowed-rates" = [
            44100
            48000
            88200
            96000
            176400
            192000
            352800
            384000
          ];
        };
      };
    };
    # PC/SC Smart Card Daemon for Yubikey
    pcscd = {
      enable = true;
      plugins = [ pkgs.ccid ];
    };
    # Mullvad VPN daemon
    mullvad-vpn.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Security
  security.rtkit.enable = true;
  security.pam.services.hyprlock = { };
  security.pam.services.greetd.enableGnomeKeyring = true;

  # Hardware support for GPG smartcards (Yubikey)
  hardware.gpgSmartcards.enable = true;

  # OpenRGB with Intel i2c support and udev rules
  services.hardware.openrgb = {
    enable = true;
    motherboard = "intel";
  };

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

  programs.zsh.enable = true;

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
