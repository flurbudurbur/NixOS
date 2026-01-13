{ pkgs, ... }:
{
  home = {
    username = "flur";
    homeDirectory = "/home/flur";
    stateVersion = "25.11";

    sessionVariables = {
      XDG_DATA_DIRS = "$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
    };
  };

  home.pointerCursor = {
    name = "BreezeX-RosePine-Linux";
    package = pkgs.rose-pine-cursor;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  programs.home-manager.enable = true;
  programs.zen-browser.enable = true;
}
