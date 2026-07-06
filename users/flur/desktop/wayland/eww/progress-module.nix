_:

{
  yuck = ''
    (defwidget progress-module [value icon class hover]
      (eventbox
        :onhover {"eww update " + class + "-hover=true"}
        :onhoverlost {"eww update " + class + "-hover=false"}
        (box
          :class {class + " module"}
          :orientation "v"
          :halign "fill"
          :hexpand true
          :valign "center"
          (box
            :orientation "v"
            :halign "center"
            :valign "center"
            :hexpand false
            :vexpand false
            :space-evenly false
            :spacing 2
            (revealer
              :transition "slideup"
              :duration "150ms"
              :reveal {hover}
              (label :class {class + "-value"} :text {value + "%"} :halign "center"))
            (circular-progress
              :class {class + "-progress"}
              :value {value}
              :thickness 3
              :start-at 75
              :clockwise true
              :width 32
              :height 32
              :halign "center"
              :valign "center"
              (label :text {icon} :halign "center" :valign "center"))))))
  '';

  scss = ''
    circular-progress label {
      margin-right: 3px;
    }
  '';
}
