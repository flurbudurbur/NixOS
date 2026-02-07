{ pkgs, ... }:
{
  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  
  # Auto-optimize store (deduplicate files)
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "weekly" ];

  # Automatic updating
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "weekly";

  # User accounts
  users.users.flur = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" ];
    shell = pkgs.zsh;
  };
  environment.shells = with pkgs; [ zsh ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    (pkgs.callPackage ./custom/fonts/bricolage.nix {})
  ];

  # Services
  services = {
    pulseaudio.enable = false;
    keyd = {
      enable = true;
      keyboards.default = {
        ids = ["*"];
        settings.main = {
          capslock = "layer(control)";
          control = "capslock";
        };
      };
    };
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
          "default.clock.allowed-rates" = [ 44100 48000 88200 96000 176400 192000 352800 384000 ];
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
  security.pam.services.hyprlock = {};

  # Hardware support for GPG smartcards (Yubikey)
  hardware.gpgSmartcards.enable = true;

  # Locale
  time.timeZone = "Europe/Amsterdam";

  # System packages (basic tools)
  environment.systemPackages = with pkgs; [
    git
    pciutils
    tree
    wget
    btop
    bat
  ];

  programs.zsh.enable = true;
}
