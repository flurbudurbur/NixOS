{ config, pkgs, ... }:

let
  c = import ../../../modules/colors.nix;
in
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

    # Rose Pine Moon theme
    theme = {
      name = "rose-pine-moon";

      # GTK4 CSS styling
      style = ''
        /* Main window */
        * {
          color: ${c.text};
          font-family: "JetBrainsMono Nerd Font", monospace;
          font-size: 14px;
        }

        /* Window background */
        .window {
          background: transparent;
        }

        .box-wrapper {
          background: ${c.rgba c.base "0.95"};
          border-radius: 10px;
          border: 2px solid ${c.rgba c.pine "0.3"};
          padding: 10px;
        }

        /* Search input */
        .input {
          background: ${c.rgba c.surface "0.8"};
          color: ${c.text};
          border: 1px solid ${c.rgba c.overlay "0.5"};
          border-radius: 8px;
          padding: 8px 12px;
          margin-bottom: 10px;
        }

        .input:focus {
          border-color: ${c.pine};
          box-shadow: 0 0 0 2px ${c.rgba c.pine "0.3"};
        }

        /* List items */
        .item {
          background: transparent;
          border-radius: 6px;
          padding: 8px 12px;
          margin: 2px 0;
        }

        .item:hover {
          background: ${c.rgba c.overlay "0.5"};
        }

        .item:selected {
          background: ${c.rgba c.pine "0.3"};
          border: 1px solid ${c.pine};
        }

        /* Item text */
        .item-text {
          color: ${c.text};
        }

        .item-sub {
          color: ${c.subtle};
          font-size: 12px;
        }

        /* Icons */
        .item-icon {
          margin-right: 10px;
        }

        /* Scrollbar */
        scrollbar {
          background: ${c.rgba c.surface "0.3"};
          border-radius: 10px;
        }

        scrollbar slider {
          background: ${c.rgba c.muted "0.5"};
          border-radius: 10px;
        }

        scrollbar slider:hover {
          background: ${c.rgba c.pine "0.6"};
        }
      '';
    };
  };
}
