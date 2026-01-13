{ ... }:

let
  c = import ./colors.nix;
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 5;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = c.rgb c.text;
          inner_color = c.rgb c.overlay;
          outer_color = c.rgb c.base;
          outline_thickness = 5;
          placeholder_text = "<span foreground=\"##${c.strip c.text}\">Password...</span>";
          shadow_passes = 2;
        }
      ];

      label = [
        # Time
        {
          monitor = "";
          text = ''cmd[update:1000] echo "<span>$(date +"%H:%M")</span>"'';
          color = c.rgb c.text;
          font_size = 120;
          font_family = "JetBrains Mono";
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
        # Date
        {
          monitor = "";
          text = ''cmd[update:1000] echo "<span>$(date +"%A, %B %d")</span>"'';
          color = c.rgb c.text;
          font_size = 20;
          font_family = "JetBrains Mono";
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
