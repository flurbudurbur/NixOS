{ ... }:
{
  services.mako = {
    enable = true;
    settings = {
      "" = {
        default-timeout = 5000;
        border-radius = 10;
        border-size = 2;
        padding = "15";
        include = "/home/flur/.config/themes/current/mako.conf";
      };
    };
  };
}
