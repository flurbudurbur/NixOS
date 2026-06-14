{ hostname, ... }:

let
  monitorConfigs = {
    flurPC = [
      {
        output = "DP-2";
        mode = "2560x1440@165";
        position = "2560x0";
        scale = "1";
      }
      {
        output = "DP-1";
        mode = "2560x1440@165";
        position = "0x0";
        scale = "1";
      }
    ];
  };
  monitors =
    monitorConfigs.${hostname} or [
      {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = "auto";
      }
    ];
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    systemd.enable = false; # UWSM handles systemd integration

    settings = {
      monitor = monitors;

      config = {
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          resize_on_border = false;
          allow_tearing = false;
          layout = "scrolling";
        };

        decoration = {
          rounding = 10;
          rounding_power = 2;
          active_opacity = 1.0;
          inactive_opacity = 1.0;
          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
          };
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
            vibrancy = 0.1696;
          };
        };

        animations = {
          enabled = true;
        };

        dwindle = {
          preserve_split = true;
        };

        master = {
          new_status = "master";
        };

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
        };

        cursor = {
          no_hardware_cursors = true;
          use_cpu_buffer = true;
          default_monitor = "DP-1";
        };

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          sensitivity = 0;
          touchpad = {
            natural_scroll = false;
          };
        };
      };

      curve = [
        {
          _args = [
            "easeOutQuint"
            {
              type = "bezier";
              points = [
                [
                  0.23
                  1
                ]
                [
                  0.32
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "easeInOutCubic"
            {
              type = "bezier";
              points = [
                [
                  0.65
                  0.05
                ]
                [
                  0.36
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "linear"
            {
              type = "bezier";
              points = [
                [
                  0
                  0
                ]
                [
                  1
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "almostLinear"
            {
              type = "bezier";
              points = [
                [
                  0.5
                  0.5
                ]
                [
                  0.75
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "quick"
            {
              type = "bezier";
              points = [
                [
                  0.15
                  0
                ]
                [
                  0.1
                  1
                ]
              ];
            }
          ];
        }
      ];

      animation = [
        {
          leaf = "global";
          enabled = true;
          speed = 10;
          bezier = "default";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 5.39;
          bezier = "easeOutQuint";
        }
        {
          leaf = "windows";
          enabled = true;
          speed = 4.79;
          bezier = "easeOutQuint";
        }
        {
          leaf = "windowsIn";
          enabled = true;
          speed = 4.1;
          bezier = "easeOutQuint";
          style = "popin 87%";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 1.49;
          bezier = "linear";
          style = "popin 87%";
        }
        {
          leaf = "fadeIn";
          enabled = true;
          speed = 1.73;
          bezier = "almostLinear";
        }
        {
          leaf = "fadeOut";
          enabled = true;
          speed = 1.46;
          bezier = "almostLinear";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 3.03;
          bezier = "quick";
        }
        {
          leaf = "layers";
          enabled = true;
          speed = 3.81;
          bezier = "easeOutQuint";
        }
        {
          leaf = "layersIn";
          enabled = true;
          speed = 4;
          bezier = "easeOutQuint";
          style = "fade";
        }
        {
          leaf = "layersOut";
          enabled = true;
          speed = 1.5;
          bezier = "linear";
          style = "fade";
        }
        {
          leaf = "fadeLayersIn";
          enabled = true;
          speed = 1.79;
          bezier = "almostLinear";
        }
        {
          leaf = "fadeLayersOut";
          enabled = true;
          speed = 1.39;
          bezier = "almostLinear";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 1.94;
          bezier = "almostLinear";
          style = "fade";
        }
        {
          leaf = "workspacesIn";
          enabled = true;
          speed = 1.21;
          bezier = "almostLinear";
          style = "fade";
        }
        {
          leaf = "workspacesOut";
          enabled = true;
          speed = 1.94;
          bezier = "almostLinear";
          style = "fade";
        }
      ];
    };

    extraConfig = ''
      -- Programs
      local terminal    = "foot"
      local fileManager = "nautilus --new-window"
      local menu        = "walker"
      local browser     = "zen-beta"
      local mainMod     = "SUPER"

      -- Environment variables
      hl.env("XCURSOR_SIZE",     "24")
      hl.env("XCURSOR_THEME",    "BreezeX-RosePine-Linux")
      hl.env("HYPRCURSOR_SIZE",  "24")
      hl.env("HYPRCURSOR_THEME", "BreezeX-RosePine-Linux")

      -- Autostart
      hl.on("hyprland.start", function()
        hl.exec_cmd("hyprctl setcursor BreezeX-RosePine-Linux 24")
      end)

      -- Keybindings
      hl.bind(mainMod .. " + Q",         hl.dsp.exec_cmd(terminal))
      hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(terminal .. " -e tmux new-session"))
      hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("grimblast copy area"))
      hl.bind(mainMod .. " + C",         hl.dsp.window.close())
      hl.bind(mainMod .. " + M",         hl.dsp.exec_cmd("hyprctl dispatch exit"))
      hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager))
      hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
      hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo())
      hl.bind(mainMod .. " + J",         hl.dsp.layout("togglesplit"))
      hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("loginctl lock-session"))
      hl.bind(mainMod .. " + Z",         hl.dsp.exec_cmd(browser))
      hl.bind("ALT + SPACE",             hl.dsp.exec_cmd(menu))

      -- Fullscreen / maximize
      hl.bind("ALT + up", hl.dsp.window.fullscreen({ mode = "maximized",  action = "toggle" }))
      hl.bind("ALT + F",  hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

      -- Move focus
      hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left"  }))
      hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
      hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up"    }))
      hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down"  }))

      -- Workspaces 1-10
      for i = 1, 10 do
        local key = i % 10
        hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
        hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
      end

      -- Special workspace
      hl.bind(mainMod .. " + S",       hl.dsp.workspace.toggle_special("magic"))
      hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:magic" }))

      -- Scroll through workspaces
      hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
      hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

      -- Swap windows
      hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "left"  }))
      hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
      hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "up"    }))
      hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "down"  }))

      -- Move window to monitor
      hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.move({ monitor = "DP-1" }))
      hl.bind(mainMod .. " + ALT + right", hl.dsp.window.move({ monitor = "DP-2" }))

      -- Resize (repeating)
      hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x =  50, y =   0, relative = true }), { repeating = true })
      hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -50, y =   0, relative = true }), { repeating = true })
      hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x =   0, y = -50, relative = true }), { repeating = true })
      hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x =   0, y =  50, relative = true }), { repeating = true })

      -- Mouse binds
      hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
      hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

      -- Media keys
      hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),   { locked = true, repeating = true })
      hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
      hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true, repeating = true })
      hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                    { locked = true, repeating = true })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                    { locked = true, repeating = true })

      hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
      hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
      hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
      hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })

      -- Window rules
      hl.window_rule({
        match    = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
        no_focus = true,
      })

      hl.window_rule({
        match = { class = "com.saivert.pwvucontrol" },
        float = true,
        size  = "600 400",
        move  = "50% 50",
      })

      hl.window_rule({
        match        = { class = "^walker$" },
        float        = true,
        center       = true,
        size         = "600 400",
        stay_focused = true,
        border_size  = 0,
      })

      -- Theme colors (overrides general/decoration defaults above)
      dofile(os.getenv("HOME") .. "/.config/themes/current/hyprland.lua")
    '';
  };
}
