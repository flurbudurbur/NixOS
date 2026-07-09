_:

{
  programs.walker = {
    enable = true;
    runAsService = true;

    config = {
      theme = "current";
      search.placeholder = "Applications";
      terminal = "foot";

      ignore_mouse = false;
      force_keyboard_focus = true;
      show_initial_entries = true;

      list = {
        height = 300;
        max_entries = 10;
      };

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

      websearch.engines = [
        {
          name = "SearXNG";
          url = "https://srx.flur.dev/search?q=%s";
        }
        {
          name = "DuckDuckGo";
          url = "https://duckduckgo.com/?q=%s";
        }
      ];
    };

    themes."current".style = ''
      @import url("/home/flur/.config/themes/current/walker-style.css");
    '';
  };
}
