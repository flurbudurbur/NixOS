{ pkgs, colors, ... }:
{
  # Hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # TUI greeter for greetd with Rose Pine Moon colors
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --asterisks --cmd 'uwsm start hyprland-uwsm.desktop' --greeting 'Welcome to NixOS' --container-padding 2 --width 80 --theme border=${colors.pine};text=${colors.text};prompt=${colors.foam};time=${colors.subtle};action=${colors.rose};button=${colors.iris};container=${colors.base};input=${colors.surface}";
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
