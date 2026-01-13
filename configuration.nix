{ lib, pkgs, ... }:

{
  # Nix Settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hardware
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
  };

  # Networking
  networking.hostName = "flurPC";
  networking.networkmanager.enable = true;

  # Localization
  time.timeZone = "Europe/Amsterdam";

  # Users
  users.users.flur = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      tree
    ];
  };
  
  # Security
  security.rtkit.enable = true;
  security.pam.services.hyprlock = {};

  # Services
  services = {
    pulseaudio.enable = false;
    flatpak.enable = true;

    # KeyD service config for setting caps lock as control
    keyd = {
      enable = true;
      keyboards = {
        # File name, can be whatevs
        default = {
          ids = ["*"];
          settings = {
            main = {
              capslock = "layer(control)";
              control = "capslock";
            };
          };
        };
      };
    };

    # GNOME services for better app integration
    gvfs.enable = true;  # Mount, trash, and other functionalities
    gnome.gnome-keyring.enable = true;  # Password/secret storage
    gnome.gnome-online-accounts.enable = false;  # Disable cloud accounts

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  # Programs
  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
    regreet = {
      enable = true;
      settings = {
        background = {
          fit = "Cover";
        };
        GTK = {
          application_prefer_dark_theme = true;
          theme_name = lib.mkForce "rose-pine-moon-gtk";
        };
      };
    };
    steam.enable = true;
    zsh.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    configPackages = [ pkgs.hyprland ];
    xdgOpenUsePortal = true;
  };

  environment.shells = with pkgs; [ zsh ];

  # Packages
  environment.systemPackages = with pkgs; [
    git
    pciutils
    tree
    wget
    alacritty
    mako
    waybar
    kdePackages.dolphin
    wofi
    rose-pine-gtk-theme
    vlc
    lutris
    wineWowPackages.stagingFull
    winetricks
    btop
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  # System
  system.stateVersion = "25.11";
}

