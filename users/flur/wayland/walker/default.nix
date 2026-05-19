{ ... }:

{
  services.walker = {
    enable = true;

    # Enable systemd service for instant startup
    systemd.enable = true;

    settings = {
      # Core settings
      search.placeholder = "Applications";
      terminal = "alacritty";

      # UI behavior
      ignore_mouse = false;
      force_keyboard_focus = true;
      show_initial_entries = true;

      # List configuration
      list = {
        height = 300;
        max_entries = 10;
      };

      # Provider configuration
      modules = [
        {
          name = "applications";
          prefix = "";
        }
        {
          name = "runner";
          prefix = ">";
        }
        {
          name = "calc";
          prefix = "=";
        }
        {
          name = "clipboard";
          prefix = ":";
        }
        {
          name = "finder";
          prefix = "/";
        }
        {
          name = "websearch";
          prefix = "@";
        }
      ];

      # Websearch providers
      websearch = {
        engines = [
          {
            name = "Google";
            url = "https://www.google.com/search?q=%s";
          }
          {
            name = "DuckDuckGo";
            url = "https://duckduckgo.com/?q=%s";
          }
        ];
      };
    };

    # Theme loaded from runtime symlink
    theme = {
      name = "current";
      style = ''
        @import url("/home/flur/.config/themes/current/walker-style.css");
      '';
    };
  };
}
