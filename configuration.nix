{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "flurPC";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";

  # services.xserver.enable = true;

  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    windowManager.qtile.enable = true;
  };
  services.displayManager.ly.enable = true;

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
 ];

fonts.packages = with pkgs; [
  nerd-fonts.jetbrains-mono
];

nix.settings.experimental-features = [ "nix-command" "flakes" ];
 system.stateVersion = "25.11";

}

