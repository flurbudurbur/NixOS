{ ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    systemd.target = "graphical-session.target";
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;
        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
          "mpris"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "wireplumber"
          "bluetooth"
          "network"
          "cpu"
          "memory"
          "tray"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
        };

        "hyprland/window" = {
          max-length = 50;
          separate-outputs = true;
        };

        mpris = {
          format = "{player_icon} {title} - {artist}";
          format-paused = "{status_icon} {title} - {artist}";
          player-icons = {
            default = "";
            spotify = "";
            firefox = "";
          };
          status-icons = {
            playing = "";
            paused = "";
          };
          max-length = 60;
          on-click = "playerctl play-pause";
          on-click-right = "playerctl next";
          on-scroll-up = "playerctl previous";
          on-scroll-down = "playerctl next";
        };

        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d %H:%M}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        cpu = {
          format = "CPU {usage}%";
          tooltip = true;
        };

        memory = {
          format = "MEM {}%";
        };

        network = {
          format-wifi = "WIFI {signalStrength}%";
          format-ethernet = "ETH";
          format-disconnected = "DISC";
          tooltip-format = "{ifname}: {ipaddr}";
        };

        wireplumber = {
          format = "VOL {volume}%";
          format-muted = " MUTED";
          format-icons = [
            ""
            ""
            ""
          ];
          on-click = "pwvucontrol";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          scroll-step = 1;
          tooltip-format = "{node_name}";
        };

        bluetooth = {
          format = "BT ON";
          format-connected = "BT {num_connections}";
          format-connected-battery = "BT {device_battery_percentage}%";
          format-disabled = "BT DISABLED";
          format-off = "BT OFF";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} CONNECTED";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} CONNECTED\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
          #on-click = "overskride";
        };

        tray = {
          spacing = 10;
        };
      };
    };
    style = ''
      @import url("/home/flur/.config/themes/current/waybar-style.css");
    '';
  };
}
