{ colors, ... }:
{
  services.mako = {
    enable = true;
    settings = {
      "" = {
        default-timeout = 5000;
        border-radius = 10;
        border-size = 2;
        padding = "15";
        background-color = colors.base;
        text-color = colors.text;
        border-color = colors.pine;
        progress-color = colors.foam;
      };
    };
  };
}
