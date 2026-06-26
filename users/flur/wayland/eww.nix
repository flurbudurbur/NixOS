{ pkgs, lib, ... }:

let
  startScript = pkgs.writeShellScript "bar-start" ''
    ${pkgs.eww}/bin/eww kill 2>/dev/null || true
    ${pkgs.eww}/bin/eww daemon --no-daemonize &
    DAEMON_PID=$!
    until ${pkgs.eww}/bin/eww state >/dev/null 2>&1; do sleep 0.1; done
    ${pkgs.eww}/bin/eww open bar
    wait $DAEMON_PID
  '';

  netScript = pkgs.writeShellScript "net-icon" ''
    t=$(nmcli -t -f TYPE,STATE connection show --active 2>/dev/null | grep activated | head -1 | cut -d: -f1)
    if [ "$t" = "wifi" ]; then
      s=$(nmcli -t -f IN-USE,SIGNAL device wifi 2>/dev/null | grep '^\*' | head -1 | cut -d: -f2)
      s=''${s:-0}
      if   [ "$s" -ge 75 ]; then echo "󰤨"
      elif [ "$s" -ge 50 ]; then echo "󰤥"
      elif [ "$s" -ge 25 ]; then echo "󰤢"
      else echo "󰤟"
      fi
    elif [ "$t" = "ethernet" ]; then
      echo "󰈀"
    else
      echo "󰤭"
    fi
  '';

  workspaceScript = pkgs.writeShellScript "workspaces" ''
    MONITORS=$(hyprctl monitors -j)
    WORKSPACES=$(hyprctl workspaces -j)
    echo "$WORKSPACES" | ${pkgs.jq}/bin/jq -c \
      --argjson m "$MONITORS" \
      '[group_by(.monitor) | .[] |
        . as $g |
        ([$m[] | select(.name == $g[0].monitor)][0]) as $mon |
        {
          monitor: ($mon.name // $g[0].monitor),
          activeWorkspace: ($mon.activeWorkspace.id // 0),
          workspaces: [$g[] | {id: .id, windows: .windows}] | sort_by(.id)
        }] | sort_by(.monitor)'
  '';
in
{
  programs.eww = {
    enable = true;
    package = pkgs.eww;
  };

  home.packages = [
    pkgs.jq
    pkgs.socat
  ];

  xdg.configFile."eww/eww.scss".text = ''
    @import "/home/flur/.config/themes/current/bar.scss";

    * {
      font-family: "Bricolage Grotesque", sans-serif;
      font-size: 13px;
      border: none;
      border-radius: 0;
    }

    .bar {
      background: transparent;
    }

    .bar-top,
    .bar-bottom {
      padding: 8px 4px;
    }

    .module {
      background: $bg-alpha;
      border-radius: 10px;
      padding: 6px 4px;
      margin: 2px 0;
    }

    .clock {
      color: $accent;
    }

    button.workspace {
      min-width: 12px;
      min-height: 12px;
      border-radius: 50%;
      padding: 0;
      margin: 0;
      background: transparent;
      border: 2px solid $fg-faint;
    }

    button.workspace.active {
      background: $accent;
      border-color: $accent;
    }

    button.workspace.occupied {
      background: $fg-dim;
      border-color: $fg-dim;
    }

    .volume-slider trough {
      background: $bg-select;
      border-radius: 9999px;
      min-width: 8px;
    }

    .volume-slider highlight {
      background: $accent;
      border-radius: 9999px;
      min-width: 8px;
    }

    .volume-slider slider {
      min-width: 0;
      min-height: 0;
      background: transparent;
      border: none;
      box-shadow: none;
    }

    .network {
      color: $cyan;
    }

    .cpu {
      color: $error;
    }

    .memory {
      color: $warning;
    }
  '';

  xdg.configFile."eww/eww.yuck".text = ''
    ;;; ─── Variables ─────────────────────────────────────────────────────────────

    (defpoll clock-time
      :interval "10s"
      "date '+%H:%M'")

    (defpoll clock-date
      :interval "60s"
      "date '+%Y-%m-%d'")

    (deflisten monitors-data
      :initial "[]"
      "${workspaceScript}; socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r _line; do ${workspaceScript}; done")

    (defpoll volume-level
      :interval "1s"
      "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{v = int($2 * 100 + 0.5); printf \"%d\", (v > 100 ? 100 : v)}'")

    (defpoll net-icon
      :interval "5s"
      "${netScript}")

    (defpoll cpu-usage
      :interval "3s"
      "top -bn1 | grep 'Cpu(s)' | awk '{print int($2)}'")

    (defpoll mem-usage
      :interval "5s"
      "free | awk '/^Mem/ {printf \"%d\", $3/$2 * 100}'")

    ;;; ─── Widgets ────────────────────────────────────────────────────────────────

    (defwidget clock []
      (box
        :class "clock module"
        :orientation "v"
        :tooltip {clock-date}
        (label :text {clock-time})))

    (defwidget workspaces []
      (box
        :class "workspaces module"
        :orientation "h"
        :spacing 4
        :space-evenly true
        (for mon in monitors-data
          (box
            :class "workspace-col"
            :orientation "v"
            :spacing 4
            :space-evenly false
            (for ws in {mon.workspaces}
              (button
                :class {ws.id == mon.activeWorkspace ? "workspace active"
                        : (ws.windows > 0 ? "workspace occupied" : "workspace empty")}
                :onclick "hyprctl dispatch workspace ''${ws.id}"
                ""))))))

    (defwidget volume []
      (scale
        :class "volume-slider module"
        :min 0
        :max 100
        :value {volume-level == "" ? 0 : volume-level}
        :onchange "wpctl set-volume @DEFAULT_AUDIO_SINK@ {}%"
        :orientation "v"
        :flipped true
        :height 80))

    (defwidget network []
      (box
        :class "network module"
        :orientation "h"
        (label :text {net-icon})))

    (defwidget cpu []
      (box
        :class "cpu module"
        :orientation "h"
        (label :text {"󰻠 " + cpu-usage + "%"})))

    (defwidget memory []
      (box
        :class "memory module"
        :orientation "h"
        (label :text {"󰍛 " + mem-usage + "%"})))

    ;;; ─── Bar layout ─────────────────────────────────────────────────────────────

    (defwidget bar-layout []
      (box
        :class "bar"
        :orientation "v"
        :vexpand true
        (box
          :class "bar-top"
          :orientation "v"
          :space-evenly false
          :valign "start"
          :spacing 8
          (clock)
          (workspaces))
        (box
          :class "bar-bottom"
          :orientation "v"
          :space-evenly false
          :valign "end"
          :vexpand true
          :spacing 4
          (volume)
          (network)
          (cpu)
          (memory))))

    ;;; ─── Windows ────────────────────────────────────────────────────────────────

    (defwindow bar
      :monitor "DP-1"
      :anchor "left center"
      :exclusive true
      :windowtype "dock"
      :stacking "fg"
      :geometry (geometry
        :x "0"
        :y "0"
        :width "50px"
        :height "100%")
      (bar-layout))
  '';

  systemd.user.services.bar = {
    Unit = {
      Description = "Status bar";
      Documentation = "https://elkowar.github.io/eww/";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${startScript}";
      Restart = "on-failure";
      RestartSec = "3s";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

}
