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
        (label :text {"${icons.memory} " + mem-usage + "%"})))
  '';

  scss = ''
    .memory {
      color: $warning;
    }
  '';
}
