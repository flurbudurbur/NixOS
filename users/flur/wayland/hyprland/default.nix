{ hostname, ... }:

let
  monitorConfigs = {
    flurPC = [
      "DP-2,2560x1440@165,2560x0,1"
      "DP-1,2560x1440@165,0x0,1"
    ];
    # Add other hostnames here, e.g.:
    # laptop = [ "eDP-1,1920x1080@60,0x0,1" ];
  };
  monitors = monitorConfigs.${hostname} or [ ",preferred,auto,1" ];
in
{
  wayland.windowManager.hyprland.extraConfig = ''
    source = /home/flur/.config/themes/current/hyprland.conf
  '';

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false; # UWSM handles systemd integration
    settings = {
      # Monitor config (per-hostname)
      monitor = monitors;

      # Programs
      "$terminal" = "foot";
      "$fileManager" = "nautilus";
      "$menu" = "walker";
      "$browser" = "zen-beta";
      "$mainMod" = "SUPER";

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,BreezeX-RosePine-Linux"
        "HYPRCURSOR_SIZE,24"
        "HYPRCURSOR_THEME,BreezeX-RosePine-Linux"
      ];

      # General settings
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
        active_opacity = 1;
        inactive_opacity = 1;
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
        bezier = [
          "easeOutQuint, 0.23, 1, 0.32, 1"
          "easeInOutCubic, 0.65, 0.05, 0.36, 1"
          "linear, 0, 0, 1, 1"
          "almostLinear, 0.5, 0.5, 0.75, 1"
          "quick, 0.15, 0, 0.1, 1"
        ];
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      exec-once = [
        "hyprctl setcursor BreezeX-RosePine-Linux 24"
      ];

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

      # Keybindings
      bind = [
        "$mainMod, Q, exec, $terminal"
        "$mainMod SHIFT, Q, exec, $terminal -e tmux new-session"
        "$mainMod SHIFT, S, exec, grimblast copy area"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating,"
        "$mainMod, P, pseudo,"
        "$mainMod, J, togglesplit,"
        "$mainMod, L, exec, loginctl lock-session"
        "$mainMod, Z, exec, $browser"
        "ALT, SPACE, exec, $menu"
        # Maximize window
        "ALT, up, fullscreen, 1"
        # True fullscreen
        "ALT, F, fullscreen, 0"
        # Move focus
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
      ]
      # Workspace bindings (1-9 and 0->10)
      ++ (builtins.concatLists (
        builtins.genList (
          i:
          let
            ws = toString (if i == 9 then 10 else i + 1);
            key = toString (if i == 9 then 0 else i + 1);
          in
          [
            "$mainMod, ${key}, workspace, ${ws}"
            "$mainMod SHIFT, ${key}, movetoworkspace, ${ws}"
          ]
        ) 10
      ))
      ++ [
        # Special workspace
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod ALT, S, movetoworkspace, special:magic"
        # Scroll workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        # Swap windows within workspace
        "$mainMod SHIFT, left, swapwindow, l"
        "$mainMod SHIFT, right, swapwindow, r"
        "$mainMod SHIFT, up, swapwindow, u"
        "$mainMod SHIFT, down, swapwindow, d"
        # Move window to other monitor
        "$mainMod ALT, left, movewindow, mon:DP-1"
        "$mainMod ALT, right, movewindow, mon:DP-2"
      ];

      # Repeating binds for resize
      binde = [
        "$mainMod CTRL, right, resizeactive, 50 0"
        "$mainMod CTRL, left, resizeactive, -50 0"
        "$mainMod CTRL, up, resizeactive, 0 -50"
        "$mainMod CTRL, down, resizeactive, 0 50"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Media keys
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # Window rules
      windowrule = [
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];

      windowrulev2 = [
        # pwvucontrol - small floating audio control window
        "float, class:(com.saivert.pwvucontrol)"
        "size 600 400, class:(com.saivert.pwvucontrol)"
        "move 50% 50, class:(com.saivert.pwvucontrol)"

        # Walker launcher
        "float, class:^(walker)$"
        "center, class:^(walker)$"
        "size 600 400, class:^(walker)$"
        "stayfocused, class:^(walker)$"
        "noborder, class:^(walker)$"
      ];
    };
  };
}
