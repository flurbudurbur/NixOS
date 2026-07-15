{
  hostname,
  lib,
  pkgs,
  ...
}:

let
  mkLua = lib.generators.mkLuaInline;
  mkBind = key: dispatch: {
    _args = [
      key
      dispatch
    ];
  };
  mkBindWith = key: dispatch: opts: {
    _args = [
      key
      dispatch
      opts
    ];
  };

  terminal = "foot";
  fileManager = "nautilus --new-window";
  menu = "walker";
  browser = "zen-beta";
  mainMod = "SUPER";

  seshToggle = (import ./eww/sesh.nix { inherit pkgs; }).toggleScript;

  monitorsData = import ./monitors.nix { inherit hostname lib; };
  inherit (monitorsData) monitors monitorCase;

  wsScript = pkgs.writeShellScript "ws-switch" ''
        WS=$1
        MON=$(hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r .monitor)
        case "$MON" in
    ${monitorCase}
          *) MON_IDX=0 ;;
        esac
        hyprctl dispatch "hl.dsp.focus({ workspace = $((MON_IDX * 10 + WS)) })"
  '';

  mvScript = pkgs.writeShellScript "ws-move" ''
        WS=$1
        MON=$(hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r .monitor)
        case "$MON" in
    ${monitorCase}
          *) MON_IDX=0 ;;
        esac
        hyprctl dispatch "hl.dsp.window.move({ workspace = $((MON_IDX * 10 + WS)) })"
  '';

  closeWsScript = pkgs.writeShellScript "ws-close" ''
        WS=$1
        MON=$(hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r .monitor)
        case "$MON" in
    ${monitorCase}
          *) MON_IDX=0 ;;
        esac
        WS_ID=$((MON_IDX * 10 + WS))
        BASE=$((MON_IDX * 10 + 1))
        if [ "$WS_ID" -eq "$BASE" ]; then
          exit 0
        fi
        NEXT_LOWEST=$(hyprctl workspaces -j | ${pkgs.jq}/bin/jq -r --argjson ws "$WS_ID" --argjson base "$BASE" \
          '[.[] | select(.id < $ws and .id >= $base) | .id] | if length > 0 then max else empty end')
        NEXT_LOWEST="''${NEXT_LOWEST:-$BASE}"
        IS_ACTIVE=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r --argjson ws "$WS_ID" '[.[] | select(.activeWorkspace.id == $ws)] | length > 0')
        BATCH=$(hyprctl clients -j | ${pkgs.jq}/bin/jq -r --argjson ws "$WS_ID" '
          [.[] | select(.workspace.id == $ws) |
            "dispatch hl.dsp.window.close({ window = \"address:" + .address + "\" })"
          ] | join(" ; ")
        ')
        if [ "$IS_ACTIVE" = "true" ]; then
          SWITCH="dispatch hl.dsp.focus({ monitor = \"$MON\" }) ; dispatch hl.dsp.focus({ workspace = $NEXT_LOWEST })"
          if [ -n "$BATCH" ]; then
            BATCH="$BATCH ; $SWITCH"
          else
            BATCH="$SWITCH"
          fi
        fi
        if [ -n "$BATCH" ]; then
          hyprctl --batch "$BATCH"
        fi
        ${pkgs.libnotify}/bin/notify-send "Closed workspace $WS on $MON"
  '';

  videoOpacityWatchScript = pkgs.writeShellScriptBin "video-opacity-watch" ''
    set -uo pipefail

    declare -A locked=()

    while true; do
      declare -A current=()
      while IFS= read -r addr; do
        [ -n "$addr" ] && current["$addr"]=1
      done < <(hyprctl clients -j | ${pkgs.jq}/bin/jq -r '.[] | select(.inhibitingIdle == true) | .address')

      for addr in "''${!current[@]}"; do
        if [ -z "''${locked[$addr]:-}" ]; then
          hyprctl setprop "address:$addr" forceopaque 1 lock >/dev/null 2>&1 || true
          locked["$addr"]=1
        fi
      done

      for addr in "''${!locked[@]}"; do
        if [ -z "''${current[$addr]:-}" ]; then
          hyprctl setprop "address:$addr" forceopaque 0 >/dev/null 2>&1 || true
          unset "locked[$addr]"
        fi
      done

      unset current
      sleep 2
    done
  '';

  workspaceBinds = builtins.concatMap (
    i:
    let
      key = toString (lib.mod i 10);
    in
    [
      (mkBind "${mainMod} + ${key}" (mkLua ''hl.dsp.exec_cmd("${wsScript} ${toString i}")''))
      (mkBind "${mainMod} + SHIFT + ${key}" (mkLua ''hl.dsp.exec_cmd("${mvScript} ${toString i}")''))
      (mkBind "${mainMod} + CTRL + ${key}" (mkLua ''hl.dsp.exec_cmd("${closeWsScript} ${toString i}")''))
    ]
  ) (lib.range 1 10);
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
          layout = "dwindle";
        };

        decoration = {
          rounding = 10;
          rounding_power = 2;
          active_opacity = 1.0;
          inactive_opacity = 0.85;
          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
          };
          blur = {
            enabled = true;
            size = 8;
            passes = 2;
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
          kb_layout = "us,us";
          kb_variant = ",intl";
          follow_mouse = 1;
          sensitivity = 0;
          touchpad = {
            natural_scroll = false;
          };
        };

        device = [ ];
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

      env = [
        {
          _args = [
            "XCURSOR_SIZE"
            "24"
          ];
        }
        {
          _args = [
            "XCURSOR_THEME"
            "BreezeX-RosePine-Linux"
          ];
        }
        {
          _args = [
            "HYPRCURSOR_SIZE"
            "24"
          ];
        }
        {
          _args = [
            "HYPRCURSOR_THEME"
            "BreezeX-RosePine-Linux"
          ];
        }
      ];

      workspace_rule = [
        {
          workspace = "1";
          monitor = "DP-1";
          default = true;
        }
        {
          workspace = "11";
          monitor = "DP-2";
          default = true;
        }
      ];

      on = {
        _args = [
          "hyprland.start"
          (mkLua ''
            function()
              hl.exec_cmd("hyprctl setcursor BreezeX-RosePine-Linux 24")
              hl.exec_cmd("wl-paste --type text --watch cliphist store")
              hl.exec_cmd("wl-paste --type image --watch cliphist store")
              hl.exec_cmd("sleep 2 && ivpn connect -f")
            end'')
        ];
      };

      bind = [
        # Programs
        (mkBind "${mainMod} + Q" (mkLua ''hl.dsp.exec_cmd("${terminal}")''))
        (mkBind "${mainMod} + SHIFT + Q" (mkLua ''hl.dsp.exec_cmd("${terminal} -e tmux new-session")''))
        (mkBind "${mainMod} + SHIFT + S" (
          mkLua ''hl.dsp.exec_cmd("hyprshot -m region --freeze --clipboard-only")''
        ))
        (mkBind "${mainMod} + C" (mkLua "hl.dsp.window.close()"))
        (mkBind "${mainMod} + SHIFT + M" (mkLua ''hl.dsp.exec_cmd("hyprctl dispatch exit")''))
        (mkBind "${mainMod} + E" (mkLua ''hl.dsp.exec_cmd("${fileManager}")''))
        (mkBind "${mainMod} + V" (mkLua ''hl.dsp.window.float({ action = "toggle" })''))
        (mkBind "${mainMod} + P" (mkLua "hl.dsp.window.pseudo()"))
        (mkBind "${mainMod} + J" (mkLua ''hl.dsp.layout("togglesplit")''))
        (mkBind "${mainMod} + L" (mkLua ''hl.dsp.exec_cmd("loginctl lock-session")''))
        (mkBind "${mainMod} + Z" (mkLua ''hl.dsp.exec_cmd("${browser}")''))
        (mkBind "ALT + SPACE" (mkLua ''hl.dsp.exec_cmd("${menu}")''))
        (mkBind "${mainMod} + SHIFT + V" (mkLua ''hl.dsp.exec_cmd("walker --modules clipboard")''))
        (mkBind "${mainMod} + SPACE" (mkLua ''hl.dsp.exec_cmd("hyprctl switchxkblayout all next")''))
        (mkBind "${mainMod} + T" (mkLua ''hl.dsp.exec_cmd("theme-switch")''))
        (mkBind "${mainMod} + SHIFT + T" (mkLua ''hl.dsp.exec_cmd("${seshToggle}")''))

        # Fullscreen / maximize
        (mkBind "ALT + up" (mkLua ''hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })''))
        (mkBind "ALT + F" (mkLua ''hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })''))

        # Move focus
        (mkBind "${mainMod} + left" (mkLua ''hl.dsp.focus({ direction = "left" })''))
        (mkBind "${mainMod} + right" (mkLua ''hl.dsp.focus({ direction = "right" })''))
        (mkBind "${mainMod} + up" (mkLua ''hl.dsp.focus({ direction = "up" })''))
        (mkBind "${mainMod} + down" (mkLua ''hl.dsp.focus({ direction = "down" })''))
      ]
      ++ workspaceBinds
      ++ [
        # Special workspace
        (mkBind "${mainMod} + S" (mkLua ''hl.dsp.workspace.toggle_special("magic")''))
        (mkBind "${mainMod} + ALT + S" (mkLua ''hl.dsp.window.move({ workspace = "special:magic" })''))

        # Scroll through workspaces
        (mkBind "${mainMod} + mouse_down" (mkLua ''hl.dsp.focus({ workspace = "e+1" })''))
        (mkBind "${mainMod} + mouse_up" (mkLua ''hl.dsp.focus({ workspace = "e-1" })''))

        # Swap windows
        (mkBind "${mainMod} + SHIFT + left" (mkLua ''hl.dsp.window.swap({ direction = "left" })''))
        (mkBind "${mainMod} + SHIFT + right" (mkLua ''hl.dsp.window.swap({ direction = "right" })''))
        (mkBind "${mainMod} + SHIFT + up" (mkLua ''hl.dsp.window.swap({ direction = "up" })''))
        (mkBind "${mainMod} + SHIFT + down" (mkLua ''hl.dsp.window.swap({ direction = "down" })''))

        # Move window to monitor
        (mkBind "${mainMod} + ALT + left" (mkLua ''hl.dsp.window.move({ monitor = "DP-1" })''))
        (mkBind "${mainMod} + ALT + right" (mkLua ''hl.dsp.window.move({ monitor = "DP-2" })''))

        # Resize (repeating)
        (mkBindWith "${mainMod} + CTRL + right"
          (mkLua "hl.dsp.window.resize({ x = 50, y = 0, relative = true })")
          { repeating = true; }
        )
        (mkBindWith "${mainMod} + CTRL + left"
          (mkLua "hl.dsp.window.resize({ x = -50, y = 0, relative = true })")
          { repeating = true; }
        )
        (mkBindWith "${mainMod} + CTRL + up"
          (mkLua "hl.dsp.window.resize({ x = 0, y = -50, relative = true })")
          { repeating = true; }
        )
        (mkBindWith "${mainMod} + CTRL + down"
          (mkLua "hl.dsp.window.resize({ x = 0, y = 50, relative = true })")
          { repeating = true; }
        )

        # Mouse binds
        (mkBindWith "${mainMod} + mouse:272" (mkLua "hl.dsp.window.drag()") { mouse = true; })
        (mkBindWith "${mainMod} + mouse:273" (mkLua "hl.dsp.window.resize()") { mouse = true; })

        # Media keys
        (mkBindWith "XF86AudioRaiseVolume"
          (mkLua ''hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")'')
          {
            locked = true;
            repeating = true;
          }
        )
        (mkBindWith "XF86AudioLowerVolume"
          (mkLua ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")'')
          {
            locked = true;
            repeating = true;
          }
        )
        (mkBindWith "XF86AudioMute"
          (mkLua ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'')
          {
            locked = true;
            repeating = true;
          }
        )
        (mkBindWith "XF86AudioMicMute"
          (mkLua ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'')
          {
            locked = true;
            repeating = true;
          }
        )
        (mkBindWith "XF86MonBrightnessUp" (mkLua ''hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+")'') {
          locked = true;
          repeating = true;
        })
        (mkBindWith "XF86MonBrightnessDown" (mkLua ''hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-")'') {
          locked = true;
          repeating = true;
        })
        (mkBindWith "XF86AudioNext" (mkLua ''hl.dsp.exec_cmd("playerctl next")'') { locked = true; })
        (mkBindWith "XF86AudioPause" (mkLua ''hl.dsp.exec_cmd("playerctl play-pause")'') { locked = true; })
        (mkBindWith "XF86AudioPlay" (mkLua ''hl.dsp.exec_cmd("playerctl play-pause")'') { locked = true; })
        (mkBindWith "XF86AudioPrev" (mkLua ''hl.dsp.exec_cmd("playerctl previous")'') { locked = true; })
      ];

      window_rule = [
        {
          match = {
            class = "^$";
            title = "^$";
            xwayland = true;
            float = true;
            fullscreen = false;
            pin = false;
          };
          no_focus = true;
        }
        {
          match = {
            class = "com.saivert.pwvucontrol";
          };
          float = true;
          size = "600 400";
          move = "50% 50";
        }
        {
          match = {
            class = "^walker$";
          };
          float = true;
          center = true;
          size = "600 400";
          stay_focused = true;
          border_size = 0;
        }
        {
          match = {
            class = "^foot$";
          };
          opacity = "0.90 0.80";
        }
      ];

      # Walker is a layer-shell surface, not a toplevel, so window_rule above
      # never matches it - use layer_rule for its own pop-in/out instead.
      layer_rule = [
        {
          match = {
            namespace = "^walker$";
          };
          animation = "popin 85%";
        }
      ];
    };

    extraConfig = ''
      dofile(os.getenv("HOME") .. "/.config/themes/current/hyprland.lua")
    '';
  };

  systemd.user.services.video-opacity-watch = {
    Unit = {
      Description = "Force full opacity on windows inhibiting idle (video playback)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${videoOpacityWatchScript}/bin/video-opacity-watch";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
