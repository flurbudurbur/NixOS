{ lib, pkgs, ... }:
{
  # GTK, Qt, and dconf theming now managed by stylix

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
    };
  };

  xdg.configFile."xdg-desktop-portal/hyprland-portals.conf".text = ''
    [preferred]
    default=hyprland;gtk
    org.freedesktop.impl.portal.FileChooser=gtk
    org.freedesktop.impl.portal.OpenURI=gtk
    org.freedesktop.impl.portal.Settings=gtk
  '';

  # Add Flatpak application directories to XDG data dirs for application launchers
  xdg.dataFile."applications/.keep".text = "";
  home.sessionVariables = {
    XDG_DATA_DIRS = "$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$XDG_DATA_DIRS";
  };

  # Propagate Flatpak paths to systemd user services (Walker, etc.)
  systemd.user.sessionVariables = {
    XDG_DATA_DIRS = "$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$XDG_DATA_DIRS";
  };
}
