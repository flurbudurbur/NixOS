{ pkgs }:

let
  startScript = pkgs.writeShellScript "bar-start" ''
    ${pkgs.eww}/bin/eww kill 2>/dev/null || true
    ${pkgs.eww}/bin/eww daemon --no-daemonize &
    DAEMON_PID=$!
    until ${pkgs.eww}/bin/eww state >/dev/null 2>&1; do sleep 0.1; done
    ${pkgs.eww}/bin/eww open bar
    wait $DAEMON_PID
  '';
in
{
  inherit startScript;

  yuck = ''
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

    (defwindow bar
      :monitor "DP-1"
      :anchor "left top bottom"
      :exclusive true
      :windowtype "dock"
      :stacking "fg"
      :geometry (geometry
        :x "-55px"
        :y "0"
        :width "55px"
        :height "100%")
      (bar-layout))
  '';

  scss = ''
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
      padding: 8px 2px;
    }

    .module {
      background: $bg-alpha;
      border-radius: 10px;
      padding: 6px 2px;
      margin: 2px 0;
    }
  '';
}
