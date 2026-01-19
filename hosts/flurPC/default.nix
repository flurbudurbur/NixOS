{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/hyprland.nix
    ../../modules/secrets.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "flurPC";
  networking.networkmanager.enable = true;

  system.stateVersion = "25.11";
}
