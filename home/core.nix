{ pkgs, ... }:
{
  home = {
    username = "flur";
    homeDirectory = "/home/flur";
    stateVersion = "25.11";
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

  stylix = {
    targets.zen-browser.profileNames = [ "default" ];
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine-moon.yaml";
    opacity.terminal = 0.95;
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font";
      };
      sansSerif = {
        package = pkgs.callPackage ../modules/custom/fonts/bricolage.nix {};
        name = "Bricolage Grotesque";
      };
      serif = {
        package = pkgs.callPackage ../modules/custom/fonts/bricolage.nix {};
        name = "Bricolage Grotesque";
      };
      sizes = {
        terminal = 12;
      };
    };
  };
}
