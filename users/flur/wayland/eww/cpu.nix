{ icons }:

{
  yuck = ''
    (defpoll cpu-usage
      :interval "3s"
      "top -bn1 | grep 'Cpu(s)' | awk '{print int($2)}'")

    (defwidget cpu []
      (box
        :class "cpu module"
        :orientation "h"
        (label :text {"${icons.cpu} " + cpu-usage + "%"})))
  '';

  scss = ''
    .cpu {
      color: $error;
    }
  '';
}
