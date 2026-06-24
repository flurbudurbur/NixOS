{ pkgs, lib, ... }:
{
  home = {
    username = "flur";
    homeDirectory = "/home/flur";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
  programs.zen-browser.enable = true;

  xdg.configFile."systemd/user.conf.d/no-status.conf".text = ''
    [Manager]
    ShowStatus=no
  '';

  stylix =
    with pkgs;
    let
      bricolage = {
        package = bricolage-grotesque;
        name = "Bricolage Grotesque";
      };
    in
    {
      enable = true;
      targets =
        lib.genAttrs
          [
            "zen-browser"
            "starship"
            "waybar"
            "hyprlock"
            "hyprland"
            "foot"
            "nixvim"
          ]
          (_: {
            enable = false;
          });
      cursor = {
        name = "BreezeX-RosePine-Linux";
        package = rose-pine-cursor;
        size = 24;
      };
      fonts = {
        monospace = {
          package = maple-mono.NF;
          name = "MapleMono NF";
        };
        sansSerif = bricolage;
        serif = bricolage;
        sizes.terminal = 12;
      };
    };
}
