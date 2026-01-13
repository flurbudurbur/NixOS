{ ... }:
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
}
