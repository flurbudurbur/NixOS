{ ... }:
{
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 10;
      border-size = 2;
      padding = "15";
      font = "Autour One 11";
      markup = 1;
      format = "<b>%s</b>\n%b";
      include = "/home/flur/.config/themes/current/mako.conf";

      "app-name=Fluxer" = {
        group-by = "app-name";
        default-timeout = 3000;
      };
    };
  };
}
