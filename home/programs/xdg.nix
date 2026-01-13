{ pkgs, ... }:
let
  c = import ../../modules/colors.nix;
in
{
  gtk = {
    enable = true;
    theme = {
      name = "rose-pine-moon";
      package = pkgs.rose-pine-gtk-theme;
    };
    iconTheme = {
      name = "rose-pine-moon";
      package = pkgs.rose-pine-icon-theme;
    };
    gtk3.extraCss = ''
      @define-color accent_bg_color ${c.iris};
      @define-color accent_fg_color ${c.base};
      @define-color accent_color ${c.iris};
      @define-color destructive_bg_color ${c.love};
      @define-color destructive_fg_color ${c.base};
      @define-color destructive_color ${c.love};
      @define-color success_bg_color ${c.foam};
      @define-color success_fg_color ${c.text};
      @define-color success_color ${c.foam};
      @define-color warning_bg_color ${c.gold};
      @define-color warning_fg_color ${c.text};
      @define-color warning_color ${c.gold};
      @define-color error_bg_color ${c.love};
      @define-color error_fg_color ${c.text};
      @define-color error_color ${c.love};
      @define-color window_bg_color ${c.base};
      @define-color window_fg_color ${c.text};
      @define-color view_bg_color ${c.surface};
      @define-color view_fg_color ${c.text};
      @define-color headerbar_bg_color ${c.base};
      @define-color headerbar_fg_color ${c.text};
      @define-color headerbar_backdrop_color @window_bg_color;
      @define-color headerbar_shade_color ${c.base};
      @define-color headerbar_border_color ${c.highlightMed};
      @define-color card_bg_color ${c.overlay};
      @define-color card_fg_color ${c.text};
      @define-color card_shade_color ${c.overlay};
      @define-color dialog_bg_color ${c.surface};
      @define-color dialog_fg_color ${c.text};
      @define-color popover_bg_color ${c.surface};
      @define-color popover_fg_color ${c.text};
      @define-color sidebar_bg_color ${c.surface};
      @define-color sidebar_fg_color ${c.text};
      @define-color sidebar_backdrop_color ${c.surface};
      @define-color sidebar_shade_color ${c.surface};
    '';
    gtk4.extraCss = ''
      @define-color accent_bg_color ${c.iris};
      @define-color accent_fg_color ${c.base};
      @define-color accent_color ${c.iris};
      @define-color destructive_bg_color ${c.love};
      @define-color destructive_fg_color ${c.base};
      @define-color destructive_color ${c.love};
      @define-color success_bg_color ${c.foam};
      @define-color success_fg_color ${c.text};
      @define-color success_color ${c.foam};
      @define-color warning_bg_color ${c.gold};
      @define-color warning_fg_color ${c.text};
      @define-color warning_color ${c.gold};
      @define-color error_bg_color ${c.love};
      @define-color error_fg_color ${c.text};
      @define-color error_color ${c.love};
      @define-color window_bg_color ${c.base};
      @define-color window_fg_color ${c.text};
      @define-color view_bg_color ${c.surface};
      @define-color view_fg_color ${c.text};
      @define-color headerbar_bg_color ${c.base};
      @define-color headerbar_fg_color ${c.text};
      @define-color headerbar_backdrop_color @window_bg_color;
      @define-color headerbar_shade_color ${c.base};
      @define-color headerbar_border_color ${c.highlightMed};
      @define-color card_bg_color ${c.overlay};
      @define-color card_fg_color ${c.text};
      @define-color card_shade_color ${c.overlay};
      @define-color dialog_bg_color ${c.surface};
      @define-color dialog_fg_color ${c.text};
      @define-color popover_bg_color ${c.surface};
      @define-color popover_fg_color ${c.text};
      @define-color shade_color rgba(0, 0, 0, 0.36);
      @define-color scrollbar_outline_color rgba(0, 0, 0, 0.5);
      @define-color sidebar_bg_color ${c.surface};
      @define-color sidebar_fg_color ${c.text};
      @define-color sidebar_backdrop_color ${c.surface};
      @define-color sidebar_shade_color ${c.surface};
      @define-color secondary_sidebar_bg_color ${c.base};
      @define-color secondary_sidebar_fg_color ${c.text};
      @define-color secondary_sidebar_backdrop_color ${c.base};
      @define-color secondary_sidebar_shade_color ${c.base};
      @define-color thumbnail_bg_color ${c.surface};
      @define-color thumbnail_fg_color ${c.text};
    '';
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "gtk2";
  };

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

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "rose-pine-moon";
      icon-theme = "rose-pine-moon";
      cursor-theme = "BreezeX-RosePine-Linux";
      cursor-size = 24;
    };
  };
}
