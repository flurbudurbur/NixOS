{ pkgs, tinted-schemes, ... }:
let
  themes = import ./themes/default.nix { schemes = tinted-schemes; };
  colors = themes.rose-pine-moon;
in
{
  # Hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  systemd.services.greetd.environment.COLORTERM = "truecolor";

  # TUI greeter for greetd with Rose Pine Moon colors
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --asterisks --cmd 'uwsm start hyprland-uwsm.desktop >/dev/null 2>&1' --greeting 'Welcome to NixOS' --container-padding 2 --width 80 --theme border=${colors.blue};text=${colors.fg};prompt=${colors.cyan};time=${colors.fg_dim};action=${colors.accent2};button=${colors.accent};container=${colors.bg};input=${colors.bg_alt}";
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
    mako
    waybar
    rose-pine-gtk-theme
    rose-pine-icon-theme
  ];
}
