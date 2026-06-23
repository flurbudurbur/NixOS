{ ... }:

let
  to = (import ./timeouts.nix).hypridle;
  min = m: m * 60;
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
      };

      listener = [
        {
          timeout = min to.lock;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = min (to.lock + to.screen_off);
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
        }
        {
          timeout = min (to.lock + to.suspend);
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
