{ config, pkgs, ... }:

let
  c = import ./colors.nix;
in
{
  home.packages = [ pkgs.walker ];

  xdg.configFile."walker/config.toml".text = ''
    theme = "rose-pine"
    terminal = "alacritty"
    ignore_mouse = false
    ssh_host_file = ""
    as_window = false
    force_keyboard_focus = true
    show_initial_entries = true
    scrollbar_policy = "automatic"

    [activation_mode]
    disabled = false
    use_alt = true

    [search]
    placeholder = "Search..."
    delay = 0
    hide_icons = false

    [list]
    max_entries = 10
    height = 300
  '';

  xdg.configFile."walker/themes/rose-pine/style.css".text = ''
    /* Rose Pine Moon Theme for Walker */

    /* Color definitions */
    @define-color base ${c.base};
    @define-color surface ${c.surface};
    @define-color overlay ${c.overlay};
    @define-color muted ${c.muted};
    @define-color subtle ${c.subtle};
    @define-color text ${c.text};
    @define-color love ${c.love};
    @define-color gold ${c.gold};
    @define-color rose ${c.rose};
    @define-color pine ${c.pine};
    @define-color foam ${c.foam};
    @define-color iris ${c.iris};
    @define-color highlight_low ${c.rgba c.rose "0.1"};
    @define-color highlight_med ${c.rgba c.rose "0.2"};
    @define-color highlight_high ${c.rgba c.rose "0.3"};

    /* Main window */
    #window {
      background-color: alpha(@base, 0.95);
      border: 2px solid @highlight_high;
      border-radius: 10px;
    }

    #box {
      background-color: transparent;
    }

    /* Search entry */
    #search {
      background-color: @surface;
      border: 1px solid @overlay;
      border-radius: 10px;
      color: @text;
      font-family: "FiraCode Nerd Font", monospace;
      font-size: 14px;
      padding: 12px 16px;
      margin: 12px;
    }

    #search:focus {
      border-color: @rose;
      outline: none;
    }

    #search placeholder {
      color: @muted;
    }

    /* Results list */
    #list {
      background-color: transparent;
      margin: 0 12px 12px 12px;
    }

    /* List items */
    #item {
      padding: 10px 14px;
      border-radius: 10px;
      margin: 2px 0;
      background-color: transparent;
      color: @text;
      font-family: "FiraCode Nerd Font", monospace;
      font-size: 13px;
    }

    #item:hover {
      background-color: @highlight_low;
    }

    #item:selected,
    #item:focus {
      background-color: @highlight_med;
      color: @rose;
    }

    #item:selected:hover {
      background-color: @highlight_high;
    }

    /* Item icon */
    #item image,
    #icon {
      margin-right: 10px;
    }

    /* Item text */
    #item label,
    #label {
      color: @text;
    }

    #item:selected label,
    #item:focus label {
      color: @rose;
    }

    /* Sub label / description */
    #sub {
      color: @subtle;
      font-size: 11px;
    }

    #item:selected #sub {
      color: @muted;
    }

    /* Scrollbar */
    scrollbar {
      background-color: transparent;
      border: none;
    }

    scrollbar slider {
      background-color: alpha(@iris, 0.3);
      border-radius: 4px;
      min-width: 6px;
      min-height: 6px;
    }

    scrollbar slider:hover {
      background-color: alpha(@iris, 0.5);
    }

    scrollbar slider:active {
      background-color: alpha(@iris, 0.7);
    }

    /* Spinner */
    #spinner {
      color: @iris;
    }

    /* Type indicator box */
    #typeahead {
      color: @foam;
      font-family: "FiraCode Nerd Font", monospace;
      font-size: 12px;
    }

    /* AI/LLM response styling */
    #aiScroll {
      background-color: @surface;
      border-radius: 10px;
      margin: 8px 12px;
      padding: 12px;
    }

    #ai {
      color: @text;
      font-family: "FiraCode Nerd Font", monospace;
      font-size: 13px;
    }
  '';
}
