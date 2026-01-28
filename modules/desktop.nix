{ pkgs, lib, ... }:
{
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
      commands = {
        reboot = [ "systemctl" "reboot" ];
        poweroff = [ "systemctl" "poweroff" ];
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

  # Desktop packages
  environment.systemPackages = with pkgs; [
    alacritty
    mako
    waybar
    rose-pine-gtk-theme
    vlc
  ];
}
