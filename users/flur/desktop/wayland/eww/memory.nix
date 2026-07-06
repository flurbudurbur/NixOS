{ icons }:

{
  yuck = ''
    (defvar memory-hover false)

    (defpoll mem-usage
      :interval "5s"
      "free | awk '/^Mem/ {printf \"%d\", $3/$2 * 100}'")

    (defwidget memory []
      (progress-module :value {mem-usage} :icon "${icons.memory}" :class "memory" :hover {memory-hover}))
  '';

  scss = ''
    .memory-progress {
      color: $warning;
      background-color: $bg-select;
    }

    .memory-value {
      color: $warning;
    }
  '';
}
