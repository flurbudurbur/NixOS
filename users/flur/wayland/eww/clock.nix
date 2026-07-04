{ }:

{
  yuck = ''
    (defpoll clock-hour
      :interval "10s"
      "date '+%H'")

    (defpoll clock-minute
      :interval "1s"
      "date '+%M'")

    (defpoll clock-date
      :interval "60s"
      "date '+%Y-%m-%d'")

    (defwidget clock []
      (box
        :class "clock module"
        :orientation "v"
        :halign "fill"
        :hexpand true
        :tooltip {clock-date}
        (label :class "clock-hour" :halign "center" :text {clock-hour})
        (label :class "clock-minute" :halign "center" :text {clock-minute})))
  '';

  scss = ''
    .clock {
      color: $accent;
      font-family: "Autour One", sans-serif;
      padding: 4px 4px;
    }

    .clock-hour,
    .clock-minute {
      font-size: 22px;
      font-weight: bold;
    }
  '';
}
