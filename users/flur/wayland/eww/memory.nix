{ icons }:

{
  yuck = ''
    (defpoll mem-usage
      :interval "5s"
      "free | awk '/^Mem/ {printf \"%d\", $3/$2 * 100}'")

    (defwidget memory []
      (box
        :class "memory module"
        :orientation "h"
        (label :text "${icons.memory}" :halign "center" :hexpand true)
        (label :text {mem-usage + "%"} :halign "center" :hexpand true)))
  '';

  scss = ''
    .memory {
      color: $warning;
    }
  '';
}
