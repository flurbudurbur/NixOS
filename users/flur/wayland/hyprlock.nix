{ lib, ... }:

let
  to = (import ./timeouts.nix).hyprlock;
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = to.grace;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = lib.mkForce [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
    };
    extraConfig = ''
      source = /home/flur/.config/themes/current/hyprlock.conf
    '';
  };
}
