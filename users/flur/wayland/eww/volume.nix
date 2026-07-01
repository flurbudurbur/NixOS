{ pkgs, icons }:

let
  vol = icons.volume;

  # Mirrors network.nix's icon-by-threshold pattern; wpctl appends "[MUTED]"
  # to its output when the sink is muted, which takes priority over level.
  iconScript = pkgs.writeShellScript "volume-icon" ''
    out=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    if echo "$out" | grep -q MUTED; then
      echo "${vol.muted}"
      exit 0
    fi
    v=$(echo "$out" | awk '{printf "%d", $2 * 100 + 0.5}')
    if   [ "$v" -ge 60 ]; then echo "${vol.high}"
    elif [ "$v" -ge 30 ]; then echo "${vol.medium}"
    elif [ "$v" -gt 0 ]; then echo "${vol.low}"
    else echo "${vol.muted}"
    fi
  '';

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
  # over; values are clamped to 3-80px (80 = the visualizer's container
  # height) since cava's ascii_max_range can still spike past it briefly
  # while autosens is catching up to a loud transient.
  cavaStream = pkgs.writeShellScript "volume-viz" ''
    ${pkgs.cava}/bin/cava -p ${cavaConfig} | awk -F';' '{
      printf "[";
      for (i = 1; i < NF; i++) {
        v = $i + 0;
        if (v < 3) v = 3;
        if (v > 80) v = 80;
        printf "%s%s", v, (i < NF - 1 ? "," : "");
      }
      printf "]\n";
      fflush();
    }'
  '';
in
{
  inherit cavaStream iconScript;

  yuck = ''
    (defpoll volume-level
      :interval "1s"
      "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{v = int($2 * 100 + 0.5); printf \"%d\", (v > 100 ? 100 : v)}'")

    (defpoll volume-icon
      :interval "1s"
      "${iconScript}")

    (deflisten cava-bars
      :initial "[3,3,3,3,3]"
      "${cavaStream}")

    (defvar volume-hover false)

    (defwidget volume []
      (eventbox
        :onhover "eww update volume-hover=true"
        :onhoverlost "eww update volume-hover=false"
        (box
          :class "volume module"
          :orientation "v"
          :space-evenly false
          :halign "fill"
          :hexpand true
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
                (box :class "volume-viz-bar" :halign "center" :valign "end" :style {"min-height: " + bar + "px"}))))
          (revealer
            :transition "slidedown"
            :duration "150ms"
            :reveal {volume-hover}
            (box
              :class "volume-hover-content"
              :orientation "h"
              :space-evenly false
              :halign "center"
              (label :class "volume-icon" :text {volume-icon}))))))
  '';

  scss = ''
    .volume-icon {
      color: $accent2;
    }

    .volume-hover-content {
      padding-top: 2px;
    }

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
