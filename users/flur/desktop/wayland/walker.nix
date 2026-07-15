{ pkgs, ... }:

{
  programs.walker = {
    enable = true;
    runAsService = true;

    # Walker v2 (Rust + elephant backend) config schema, see resources/config.toml upstream
    config = {
      theme = "current";

      force_keyboard_focus = true;
      disable_mouse = false;
      single_click_activation = true;
      selection_wrap = true;
      close_when_open = true;
      click_to_close = true;
      keybind_symbols = true;
      hide_quick_activation = false;
      hide_action_hints = false;
      ext_background_effect_blur = true;

      shell = {
        exclusive_zone = -1;
        layer = "overlay";
        anchor_top = true;
        anchor_bottom = true;
        anchor_left = true;
        anchor_right = true;
      };

      columns = {
        symbols = 6;
      };

      placeholders = {
        default = {
          input = "Search";
          list = "Nothing found";
        };
        desktopapplications = {
          input = "Search applications...";
          list = "No matching applications";
        };
        calc = {
          input = "Calculate anything...";
          list = "No result";
        };
        websearch = {
          input = "Search the web...";
          list = "No results";
        };
        clipboard = {
          input = "Search clipboard history...";
          list = "Clipboard is empty";
        };
        files = {
          input = "Search files...";
          list = "No files found";
        };
        runner = {
          input = "Run a command...";
          list = "No matching commands";
        };
        bookmarks = {
          input = "Search bookmarks...";
          list = "No bookmarks saved";
        };
        todo = {
          input = "Add or search todos...";
          list = "No todos yet";
        };
        symbols = {
          input = "Search symbols...";
          list = "No matching symbols";
        };
        windows = {
          input = "Switch window...";
          list = "No windows open";
        };
        providerlist = {
          input = "Choose a provider...";
          list = "No providers";
        };
        "menus:searxng" = {
          input = "Live search (SearXNG)...";
          list = "No results";
        };
      };

      providers = {
        default = [
          "desktopapplications"
          "calc"
          "websearch"
        ];
        empty = [ "desktopapplications" ];
        max_results = 50;

        max_results_provider = {
          calc = 3;
          websearch = 5;
          clipboard = 25;
        };

        clipboard.time_format = "relative";

        prefixes = [
          {
            prefix = ";";
            provider = "providerlist";
          }
          {
            prefix = ">";
            provider = "runner";
          }
          {
            prefix = "/";
            provider = "files";
          }
          {
            prefix = ".";
            provider = "symbols";
          }
          {
            prefix = "!";
            provider = "todo";
          }
          {
            prefix = "%";
            provider = "bookmarks";
          }
          {
            prefix = "=";
            provider = "calc";
          }
          {
            prefix = "@";
            provider = "websearch";
          }
          {
            prefix = "?";
            provider = "menus:searxng";
          }
          {
            prefix = ":";
            provider = "clipboard";
          }
          {
            prefix = "$";
            provider = "windows";
          }
        ];
      };
    };

    themes."current" = {
      style = ''
        @import url("/home/flur/.config/themes/current/walker-style.css");
      '';

      # ids required by src/ui/window.rs: Window, Scroll, List, ElephantHint,
      # Error, BoxWrapper, ContentContainer, Keybinds, GlobalKeybinds, ItemKeybinds
      layouts.layout = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <interface>
          <requires lib="gtk" version="4.0"></requires>
          <object class="GtkWindow" id="Window">
            <style>
              <class name="window"></class>
            </style>
            <property name="resizable">true</property>
            <property name="title">Walker</property>
            <child>
              <object class="GtkBox" id="BoxWrapper">
                <style>
                  <class name="box-wrapper"></class>
                </style>
                <property name="overflow">hidden</property>
                <property name="orientation">horizontal</property>
                <property name="valign">center</property>
                <property name="halign">center</property>
                <property name="spacing">20</property>
                <property name="height-request">640</property>
                <child>
                  <object class="GtkBox" id="LeftColumn">
                    <style>
                      <class name="left-column"></class>
                    </style>
                    <property name="orientation">vertical</property>
                    <property name="width-request">480</property>
                    <property name="spacing">16</property>
                    <child>
                      <object class="GtkBox" id="SearchContainer">
                        <style>
                          <class name="search-container"></class>
                        </style>
                        <property name="overflow">hidden</property>
                        <property name="orientation">horizontal</property>
                        <property name="halign">fill</property>
                        <property name="hexpand-set">true</property>
                        <property name="hexpand">true</property>
                        <property name="spacing">8</property>
                        <child>
                          <object class="GtkImage" id="SearchIcon">
                            <style>
                              <class name="search-icon"></class>
                            </style>
                            <property name="icon-name">system-search-symbolic</property>
                            <property name="icon-size">normal</property>
                          </object>
                        </child>
                        <child>
                          <object class="GtkEntry" id="Input">
                            <style>
                              <class name="input"></class>
                            </style>
                            <property name="halign">fill</property>
                            <property name="hexpand-set">true</property>
                            <property name="hexpand">true</property>
                          </object>
                        </child>
                      </object>
                    </child>
                    <child>
                      <object class="GtkImage" id="LeftWatermark">
                        <style>
                          <class name="left-watermark"></class>
                        </style>
                        <property name="file">${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg</property>
                        <property name="pixel-size">140</property>
                        <property name="hexpand">true</property>
                        <property name="vexpand">true</property>
                        <property name="valign">center</property>
                        <property name="halign">center</property>
                      </object>
                    </child>
                    <child>
                      <object class="GtkLabel" id="LeftLegend">
                        <style>
                          <class name="left-legend"></class>
                        </style>
                        <property name="label">= calc''\n@ web''\n? live-search''\n: clipboard''\n/ files''\n! todo''\n% marks''\n$ windows''\n&gt; run</property>
                        <property name="wrap">false</property>
                        <property name="justify">0</property>
                        <property name="xalign">0</property>
                      </object>
                    </child>
                  </object>
                </child>
                <child>
                  <object class="GtkBox" id="MiddleColumn">
                    <style>
                      <class name="middle-column"></class>
                    </style>
                    <property name="orientation">vertical</property>
                    <property name="hexpand-set">true</property>
                    <property name="hexpand">true</property>
                    <property name="width-request">600</property>
                    <property name="spacing">10</property>
                    <child>
                      <object class="GtkBox" id="ContentContainer">
                        <style>
                          <class name="content-container"></class>
                        </style>
                        <property name="orientation">horizontal</property>
                        <property name="spacing">10</property>
                        <child>
                          <object class="GtkLabel" id="ElephantHint">
                            <style>
                              <class name="elephant-hint"></class>
                            </style>
                            <property name="label">Waiting for elephant...</property>
                            <property name="hexpand">true</property>
                            <property name="vexpand">true</property>
                            <property name="visible">false</property>
                            <property name="valign">0.5</property>
                          </object>
                        </child>
                        <child>
                          <object class="GtkLabel" id="Placeholder">
                            <style>
                              <class name="placeholder"></class>
                            </style>
                            <property name="label">No Results</property>
                            <property name="hexpand">true</property>
                            <property name="vexpand">true</property>
                            <property name="valign">0.5</property>
                          </object>
                        </child>
                        <child>
                          <object class="GtkScrolledWindow" id="Scroll">
                            <style>
                              <class name="scroll"></class>
                            </style>
                            <property name="can_focus">false</property>
                            <property name="overlay-scrolling">true</property>
                            <property name="hexpand">true</property>
                            <property name="vexpand">true</property>
                            <property name="max-content-width">560</property>
                            <property name="min-content-width">560</property>
                            <property name="max-content-height">460</property>
                            <property name="propagate-natural-height">true</property>
                            <property name="propagate-natural-width">true</property>
                            <property name="hscrollbar-policy">automatic</property>
                            <property name="vscrollbar-policy">automatic</property>
                            <child>
                              <object class="GtkGridView" id="List">
                                <style>
                                  <class name="list"></class>
                                </style>
                                <property name="max_columns">1</property>
                                <property name="min_columns">1</property>
                                <property name="can_focus">false</property>
                              </object>
                            </child>
                          </object>
                        </child>
                      </object>
                    </child>
                    <child>
                      <object class="GtkBox" id="Keybinds">
                        <property name="hexpand">true</property>
                        <property name="margin-top">10</property>
                        <style>
                          <class name="keybinds"></class>
                        </style>
                        <child>
                          <object class="GtkBox" id="GlobalKeybinds">
                            <property name="spacing">10</property>
                            <style>
                              <class name="global-keybinds"></class>
                            </style>
                          </object>
                        </child>
                        <child>
                          <object class="GtkBox" id="ItemKeybinds">
                            <property name="hexpand">true</property>
                            <property name="halign">end</property>
                            <property name="spacing">10</property>
                            <style>
                              <class name="item-keybinds"></class>
                            </style>
                          </object>
                        </child>
                      </object>
                    </child>
                    <child>
                      <object class="GtkLabel" id="Error">
                        <style>
                          <class name="error"></class>
                        </style>
                        <property name="xalign">0</property>
                        <property name="visible">false</property>
                      </object>
                    </child>
                  </object>
                </child>
                <!-- Rust toggles Preview's visibility per-selection, collapsing
                     it to zero width when there's no preview content -->
                <child>
                  <object class="GtkBox" id="Preview">
                    <style>
                      <class name="preview"></class>
                    </style>
                    <property name="valign">fill</property>
                    <property name="vexpand">true</property>
                  </object>
                </child>
              </object>
            </child>
          </object>
        </interface>
      '';
    };
  };

  # Websearch engines + default terminal now live in elephant's own config
  # (provider .so backend), not walker's config.toml.
  programs.elephant = {
    settings = {
      terminal_cmd = "foot";
    };

    provider.websearch.settings.entries = [
      {
        name = "SearXNG";
        default = true;
        url = "https://srx.flur.dev/search?q=%TERM%";
      }
      {
        name = "DuckDuckGo";
        url = "https://duckduckgo.com/?q=%TERM%";
      }
    ];

    # elephant has no compiled search-result provider - "menus" is the extension point
    provider.menus.lua.searxng = ''
      Name = "searxng"
      NamePretty = "SearXNG"
      Icon = "system-search-symbolic"
      Description = "Live web search via self-hosted SearXNG"
      Action = "xdg-open %VALUE%"

      -- flurLab over the wg0 mesh directly, not the public srx.flur.dev
      local SEARXNG_URL = "http://10.100.0.2:8080/search"
      local MIN_QUERY_LEN = 3
      local MAX_RESULTS = 8
      local CURL_TIMEOUT = "2"

      local Q = string.char(39) -- single quote

      -- SearXNG results are untrusted; every value reaching a shell command must be quoted
      local function shellescape(s)
          return Q .. s:gsub(Q, Q .. "\\" .. Q .. Q) .. Q
      end

      function GetEntries(query)
          local entries = {}

          if query == nil or #query < MIN_QUERY_LEN then
              return entries
          end

          local cmd = "curl -s --max-time " .. CURL_TIMEOUT ..
              " -G --data-urlencode " .. shellescape("q=" .. query) ..
              " --data-urlencode " .. shellescape("format=json") ..
              " " .. shellescape(SEARXNG_URL)

          local handle = io.popen(cmd)
          if handle == nil then
              return entries
          end

          local body = handle:read("*a")
          handle:close()

          if body == nil or body == "" then
              return entries
          end

          local decoded = jsonDecode(body)
          if type(decoded) ~= "table" or decoded.results == nil then
              return entries
          end

          for i, r in ipairs(decoded.results) do
              if i > MAX_RESULTS then
                  break
              end

              if r.url ~= nil then
                  table.insert(entries, {
                      Text = r.title or r.url,
                      Subtext = r.url,
                      Value = shellescape(r.url),
                      -- survives elephant's own fuzzy re-filtering (min_score)
                      Keywords = { query },
                      Preview = r.content or "",
                      PreviewType = "text",
                      Icon = "system-search-symbolic",
                  })
              end
          end

          return entries
      end
    '';
  };
}
