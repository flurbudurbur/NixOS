{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "flurPC";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";
  
  programs.hyprland.enable = true;
  services.displayManager.ly.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
  };

  hardware.graphics.enable = true;

  users.users.flur = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim 
    wget
    git
    alacritty
    waybar
    kitty
    wofi
    hyprpaper
    mako
    pciutils
  ];

fonts.packages = with pkgs; [
  nerd-fonts.jetbrains-mono
];

nix.settings.experimental-features = [ "nix-command" "flakes" ];
 system.stateVersion = "25.11";

}

