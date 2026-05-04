{ pkgs, ... }:
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

  stylix = {
    targets.zen-browser.profileNames = [ "default" ];
    targets.starship.enable = false; # Custom starship config
    targets.waybar.enable = false; # Custom CSS with colors module
    targets.hyprlock.enable = false; # Custom colors with colors module
    targets.nixvim.enable = false; # Explicit rose-pine colorscheme in nixvim
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine-moon.yaml";
    opacity.terminal = 0.95;
    cursor = {
      name = "BreezeX-RosePine-Linux";
      package = pkgs.rose-pine-cursor;
      size = 24;
    };
    fonts = {
      monospace = {
        package = pkgs.maple-mono.NF;
        name = "MapleMono NF";
      };
      sansSerif = {
        package = pkgs.bricolage-grotesque;
        name = "Bricolage Grotesque";
      };
      serif = {
        package = pkgs.bricolage-grotesque;
        name = "Bricolage Grotesque";
      };
      sizes = {
        terminal = 12;
      };
    };
  };
}
