{ pkgs, lib, ... }:

{
  programs.eww = {
    enable = true;
    package = pkgs.eww;
  };

  home.packages = [
    pkgs.jq
    pkgs.socat
    pkgs.playerctl
  ];

  xdg.configFile."eww/eww.scss".text = ''
    @import "/home/flur/.config/themes/current/eww-style.scss";
  '';

  xdg.configFile."eww/eww.yuck".text = ''
    ;;; ─── Variables ─────────────────────────────────────────────────────────────

    (defpoll clock-time
      :interval "10s"
      "date '+%H:%M'")

    (defpoll clock-date
      :interval "60s"
      "date '+%Y-%m-%d'")

    (deflisten workspaces
      :initial "[]"
      "hyprctl workspaces -j | jq -c 'sort_by(.id)'; socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r _line; do hyprctl workspaces -j | jq -c 'sort_by(.id)'; done")

    (deflisten active-workspace
      :initial "1"
      "hyprctl activeworkspace -j | jq '.id'; socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r _line; do hyprctl activeworkspace -j | jq '.id'; done")

    (defpoll mpris-status
      :interval "2s"
      "playerctl status 2>/dev/null || echo Stopped")

    (defpoll volume-level
      :interval "1s"
      "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{v = int($2 * 100 + 0.5); printf \"%d\", (v > 100 ? 100 : v)}'")


    (defpoll volume-muted
      :interval "1s"
      "wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo true || echo false")

    (defpoll bt-status
      :interval "5s"
      "bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl info 2>/dev/null | grep -q 'Connected: yes' && echo connected || (bluetoothctl show | grep -q 'Powered: yes' && echo on || echo off)")

    (defpoll net-info
      :interval "5s"
      "nmcli -t -f NAME,TYPE,STATE connection show --active 2>/dev/null | grep activated | head -1 | cut -d: -f1 || echo None")

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
        :orientation "h"
        :tooltip {clock-date}
        (label :text {clock-time})))

    (defwidget workspaces []
      (box
        :class "workspaces module"
        :orientation "v"
        :space-evenly false
        :spacing 4
        (for ws in workspaces
          (button
            :class {ws.id == active-workspace ? "workspace active" : "workspace"}
            :onclick "hyprctl dispatch \"workspace ''${ws.id}\""
            {ws.id}))))

    (defwidget mpris []
      (box
        :class {mpris-status == "Playing" ? "mpris module playing" : (mpris-status == "Paused" ? "mpris module paused" : "mpris module stopped")}
        :orientation "v"
        :space-evenly false
        :visible {mpris-status != "Stopped"}
        (button :onclick "playerctl previous" "⏮")
        (button :onclick "playerctl play-pause" {mpris-status == "Playing" ? "⏸" : "▶"})
        (button :onclick "playerctl next" "⏭")))
    
    (defwidget volume []
      (box
        :class {volume-muted == "true" ? "volume module muted" : "volume module"}
        :orientation "v"
        :space-evenly false
        :spacing 6
        (button
          :onclick "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          {(volume-muted == "true" ? "󰖁 " : "󰕾 ") + volume-level + "%"})
        (scale
          :class "volume-slider"
          :min 0
          :max 100
          :value {volume-level == "" ? 0 : volume-level}
          :onchange "wpctl set-volume @DEFAULT_AUDIO_SINK@ {}%"
          :orientation "v"
          :flipped true
          :height 80)))

    (defwidget bluetooth []
      (box
        :class {"bluetooth module " + bt-status}
        :orientation "h"
        (label
          :text {(bt-status == "connected" ? "󰂱" : (bt-status == "on" ? "󰂯" : "󰂲")) + " BT"})))

    (defwidget network []
      (box
        :class "network module"
        :orientation "h"
        (label :text {"󰤨 " + net-info})))

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
          :vexpand true
          (workspaces)
          (mpris))
        (box
          :class "bar-center"
          :orientation "v"
          :valign "center"
          :vexpand true
          (clock))
        (box
          :class "bar-bottom"
          :orientation "v"
          :space-evenly false
          :valign "end"
          :vexpand true
          :spacing 4
          (volume)
          (bluetooth)
          (network)
          (cpu)
          (memory))))

    ;;; ─── Windows ────────────────────────────────────────────────────────────────

    (defwindow bar
      :monitor "DP-1"
      :type "dock"
      :anchor "left center"
      :exclusive true
      :stacking "fg"
      :geometry (geometry
        :width "50px"
        :height "100%")
      (bar-layout))
  '';

  systemd.user.services.eww-bar = {
    Unit = {
      Description = "Eww status bar";
      Documentation = "https://elkowar.github.io/eww/";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.eww}/bin/eww kill || true";
      ExecStart = "${pkgs.eww}/bin/eww daemon --no-daemonize";
      ExecStartPost = "${pkgs.eww}/bin/eww open bar";
      Restart = "on-failure";
      RestartSec = "3s";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
