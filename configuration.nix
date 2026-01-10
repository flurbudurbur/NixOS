{ config, lib, pkgs, ... }:

{
  imports = [
  ];

  # Nix Settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hardware
  hardware.graphics.enable = true;

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

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
          user = "greeter";
        };
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  # Programs
  programs = {
    hyprland.enable = true;
    steam.enable = true;
  };

  # Packages
  environment.systemPackages = with pkgs; [
    vim
    git
    pciutils
    tree
    wget
    alacritty
    kitty
    mako
    waybar
    wofi
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  # System
  system.stateVersion = "25.11";
}

