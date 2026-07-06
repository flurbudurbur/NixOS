{ pkgs, icons }:

let
  net = icons.network;
  script = pkgs.writeShellScript "net-icon" ''
    t=$(nmcli -t -f TYPE,STATE connection show --active 2>/dev/null | grep activated | head -1 | cut -d: -f1)
    if echo "$t" | grep -q "wireless\|wifi"; then
      s=$(nmcli -t -f IN-USE,SIGNAL device wifi 2>/dev/null | grep '^\*' | head -1 | cut -d: -f2)
      s=''${s:-0}
      if   [ "$s" -ge 75 ]; then echo "${net.full}"
      elif [ "$s" -ge 50 ]; then echo "${net.high}"
      elif [ "$s" -ge 25 ]; then echo "${net.medium}"
      else echo "${net.low}"
      fi
    elif echo "$t" | grep -q "ethernet"; then
      echo "${net.ethernet}"
    else
      echo "${net.off}"
    fi
  '';

  # Speed is normalized to a 0-100 scale (sqrt curve, capped at netSpeedCapKbps)
  # rather than left as raw KB/s, so the graph can use a literal :min/:max —
  # eww's :flip-y mirroring only takes effect with literal bounds, not
  # :dynamic true or variable-bound min/max (tested against eww 0.6.0).
  netSpeedCapKbps = 50000;
  speedScript = pkgs.writeShellScript "net-speed" ''
    dir="$1"
    iface=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
    if [ -z "$iface" ]; then echo 0; exit 0; fi

    statfile="/sys/class/net/$iface/statistics/''${dir}_bytes"
    if [ ! -f "$statfile" ]; then echo 0; exit 0; fi

    bytes=$(cat "$statfile")
    now=$(date +%s%N)
    state="/tmp/eww-net-''${dir}-state"

    if [ -f "$state" ]; then
      read -r pbytes ptime < "$state"
      echo "$bytes $now" > "$state"
      awk -v b="$bytes" -v pb="$pbytes" -v t="$now" -v pt="$ptime" -v cap="${toString netSpeedCapKbps}" 'BEGIN {
        dt = (t - pt) / 1000000000;
        if (dt <= 0) { print 0; exit }
        rate = (b - pb) / dt / 1024;
        if (rate < 0) rate = 0;
        pct = sqrt(rate / cap) * 100;
        if (pct > 100) pct = 100;
        printf "%d\n", pct;
      }'
    else
      echo "$bytes $now" > "$state"
      echo 0
    fi
  '';
in
{
  inherit script speedScript;

  yuck = ''
    (defpoll net-icon
      :interval "5s"
      "${script}")

    (defpoll net-down-speed
      :interval "2s"
      "${speedScript} rx")

    (defpoll net-up-speed
      :interval "2s"
      "${speedScript} tx")

    (defwidget net-graph [value class flipy]
      (graph
        :class {"net-graph " + class}
        :value {value == "" ? 0 : value}
        :thickness 2
        :time-range "30s"
        :min 0
        :max 100
        :vertical true
        :flip-x true
        :flip-y flipy
        :line-style "round"
        :width 21
        :height 64))

    (defvar network-hover false)

    (defwidget network []
      (eventbox
        :onhover "eww update network-hover=true"
        :onhoverlost "eww update network-hover=false"
        (box
          :class "network module"
          :orientation "v"
          :space-evenly false
          :halign "center"
          :spacing 4
          (box
            :orientation "h"
            :space-evenly true
            :halign "center"
            :spacing 4
            (net-graph :value {net-down-speed} :class "net-graph-down" :flipy true)
            (net-graph :value {net-up-speed} :class "net-graph-up" :flipy false))
          (revealer
            :transition "slidedown"
            :duration "150ms"
            :reveal {network-hover}
            (box
              :orientation "h"
              :space-evenly true
              :halign "center"
              :spacing 4
              (box :width 21 :halign "center"
                (label :class "net-arrow net-arrow-down" :text "${net.arrows.down}"))
              (box :width 21 :halign "center"
                (label :class "net-arrow net-arrow-up" :text "${net.arrows.up}"))))
          (label :text {net-icon}))))
  '';

  scss = ''
    .network {
      color: $cyan;
    }

    .net-graph-down {
      color: $cyan;
    }

    .net-graph-up {
      color: $blue;
    }

    .net-arrow-down {
      color: $cyan;
    }

    .net-arrow-up {
      color: $blue;
    }
  '';
}
