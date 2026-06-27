{ }:

{
  yuck = ''
    (defpoll clock-time
      :interval "10s"
      "date '+%H:%M'")

    (defpoll clock-date
      :interval "60s"
      "date '+%Y-%m-%d'")

    (defwidget clock []
      (box
        :class "clock module"
        :orientation "v"
        :tooltip {clock-date}
        (label :text {clock-time})))
  '';

  scss = ''
    .clock {
      color: $accent;
    }
  '';
}
