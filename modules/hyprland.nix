{ pkgs, lib, ... }:
{
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

  # Hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.regreet = {
    enable = true;
    settings = {
      background.fit = "Cover";
      GTK = {
        application_prefer_dark_theme = true;
        theme_name = lib.mkForce "rose-pine-moon-gtk";
      };
    };
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

  # Wayland/Desktop packages
  environment.systemPackages = with pkgs; [
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
  ];
}
