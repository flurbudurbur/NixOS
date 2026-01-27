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

    # Enable power management (required for suspend/resume)
    powerManagement.enable = true;

    # Experimental feature: save/restore GPU state on suspend
    # This helps prevent GPU crashes after resume
    powerManagement.finegrained = false;
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

  # Wayland/Desktop packages
  environment.systemPackages = with pkgs; [
    alacritty
    mako
    waybar
    rose-pine-gtk-theme
    vlc
    lutris
    wineWowPackages.stagingFull
    winetricks
  ];
}
