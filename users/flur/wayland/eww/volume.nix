{ }:

{
  yuck = ''
    (defpoll volume-level
      :interval "1s"
      "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{v = int($2 * 100 + 0.5); printf \"%d\", (v > 100 ? 100 : v)}'")

    (defwidget volume []
      (scale
        :class "volume-slider module"
        :min 0
        :max 100
        :value {volume-level == "" ? 0 : volume-level}
        :onchange "wpctl set-volume @DEFAULT_AUDIO_SINK@ {}%"
        :orientation "v"
        :flipped true
        :height 80))
  '';

  scss = ''
    .volume-slider trough {
      background: $bg-select;
      border-radius: 9999px;
      min-width: 8px;
    }

    .volume-slider highlight {
      background: $accent;
      border-radius: 9999px;
      min-width: 8px;
    }

    .volume-slider slider {
      min-width: 0;
      min-height: 0;
      background: transparent;
      border: none;
      box-shadow: none;
    }
  '';
}
