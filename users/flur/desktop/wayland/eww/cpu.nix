{ icons }:

{
  yuck = ''
    (defvar cpu-hover false)

    (defpoll cpu-usage
      :interval "3s"
      "top -bn1 | grep 'Cpu(s)' | awk '{print int($2)}'")

    (defwidget cpu []
      (progress-module :value {cpu-usage} :icon "${icons.cpu}" :class "cpu" :hover {cpu-hover}))
  '';

  scss = ''
    .cpu-progress {
      color: $error;
      background-color: $bg-select;
    }

    .cpu-value {
      color: $error;
    }
  '';
}
