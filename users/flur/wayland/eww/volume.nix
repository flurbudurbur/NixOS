{ pkgs }:

let
  cavaConfig = pkgs.writeText "cava-volume-viz.conf" ''
    [general]
    bars = 5
    autosens = 1
    sensitivity = 100

    [input]
    method = pulse
    source = auto

    [output]
    method = raw
    raw_target = /dev/stdout
    data_format = ascii
    bar_delimiter = 59
    frame_delimiter = 10
    ascii_max_range = 80
    channels = mono
  '';

  # Streams cava's ";"-separated bar values as a JSON array eww can `for`-loop
  # over; values are clamped to a 3px floor so idle bars stay visible.
  cavaStream = pkgs.writeShellScript "volume-viz" ''
    ${pkgs.cava}/bin/cava -p ${cavaConfig} | awk -F';' '{
      printf "[";
      for (i = 1; i < NF; i++) {
        v = $i + 0;
        if (v < 3) v = 3;
        printf "%s%s", v, (i < NF - 1 ? "," : "");
      }
      printf "]\n";
      fflush();
    }'
  '';
in
{
  inherit cavaStream;

  yuck = ''
    (defpoll volume-level
      :interval "1s"
      "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{v = int($2 * 100 + 0.5); printf \"%d\", (v > 100 ? 100 : v)}'")

    (deflisten cava-bars
      :initial "[3,3,3,3,3]"
      "${cavaStream}")

    (defwidget volume []
      (box
        :class "volume module"
        :orientation "h"
        :hexpand true
        :halign "fill"
        :valign "center"
        (box
          :orientation "h"
          :space-evenly false
          :spacing 2
          :halign "center"
          (scale
            :class "volume-slider"
            :min 0
            :max 100
            :value {volume-level == "" ? 0 : volume-level}
            :onchange "wpctl set-volume @DEFAULT_AUDIO_SINK@ {}%"
            :orientation "v"
            :flipped true
            :width 4
            :height 80)
          (box
            :class "volume-viz"
            :orientation "h"
            :space-evenly true
            :halign "center"
            :valign "end"
            :width 28
            :height 80
            (for bar in {cava-bars}
              (box :class "volume-viz-bar" :halign "center" :valign "end" :style {"min-height: " + bar + "px"}))))))
  '';

  scss = ''
    .volume-slider {
      padding: 0;
      margin: 0;
      min-width: 0;
    }

    .volume-slider contents {
      padding: 0;
      margin: 0;
      min-width: 0;
    }

    .volume-slider trough {
      background: $bg-select;
      border-radius: 9999px;
      min-width: 4px;
    }

    .volume-slider highlight {
      background: $accent;
      border-radius: 9999px;
      min-width: 4px;
    }

    .volume-slider slider {
      min-width: 0;
      min-height: 0;
      background: transparent;
      border: none;
      box-shadow: none;
    }

    .volume-viz-bar {
      min-width: 2px;
      background: $accent2;
      border-radius: 1px;
    }
  '';
}
