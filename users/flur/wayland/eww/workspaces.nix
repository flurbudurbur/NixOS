{
  pkgs,
  icons,
  primaryMonitor,
}:

let
  ws = icons.workspace;
  jq = "${pkgs.jq}/bin/jq";
  wsPerMonitor = 10;
  saveFocus = ''
    FOCUSED_MON=$(hyprctl monitors -j | ${jq} -r '.[] | select(.focused == true)')
    CURRENT_MON=$(echo "$FOCUSED_MON" | ${jq} -r '.name')
    CURRENT_WS=$(echo "$FOCUSED_MON" | ${jq} -r '.activeWorkspace.id')
    CURSOR=$(hyprctl cursorpos -j)
    CURSOR_X=$(echo "$CURSOR" | ${jq} -r '.x')
    CURSOR_Y=$(echo "$CURSOR" | ${jq} -r '.y')
  '';
  restoreFocusDispatch = ''dispatch hl.dsp.focus({ monitor = \"$CURRENT_MON\" }) ; dispatch hl.dsp.focus({ workspace = $CURRENT_WS }) ; dispatch hl.dsp.cursor.move({x = $CURSOR_X, y = $CURSOR_Y})'';
  switchWsScript = pkgs.writeShellScript "switch-workspace" ''
    WS_ID="$1"
    MON="$2"
    if [ "$MON" != "${primaryMonitor}" ]; then
      ${saveFocus}
      hyprctl --batch "dispatch hl.dsp.focus({ monitor = \"$MON\" }) ; dispatch hl.dsp.focus({ workspace = $WS_ID }) ; ${restoreFocusDispatch}"
    else
      hyprctl dispatch "hl.dsp.focus({ workspace = \"$WS_ID\" })"
    fi
  '';
  closeWsScript = pkgs.writeShellScript "close-workspace" ''
    WS_ID="$1"
    BASE=$(( ((WS_ID - 1) / ${toString wsPerMonitor}) * ${toString wsPerMonitor} + 1 ))
    if [ "$WS_ID" -eq "$BASE" ]; then
      exit 0
    fi
    WINDOWS=$(hyprctl clients -j | ${jq} -r --argjson ws "$WS_ID" '.[] | select(.workspace.id == $ws) | .address')
    BATCH=""
    for addr in $WINDOWS; do
      BATCH="$BATCH dispatch hl.dsp.focus({ window = \"address:$addr\" }) ; dispatch hl.dsp.window.close() ;"
    done
    if [ -n "$BATCH" ]; then
      ${saveFocus}
      BATCH="$BATCH dispatch hl.dsp.focus({ workspace = $BASE }) ; ${restoreFocusDispatch} ;"
      hyprctl --batch "$BATCH"
    fi
    DISPLAY_NUM=$(( (WS_ID - 1) / ${toString wsPerMonitor} + 1 ))
    WS_NUM=$(( (WS_ID - 1) % ${toString wsPerMonitor} + 1 ))
    ${pkgs.libnotify}/bin/notify-send "Closed workspace $WS_NUM on display $DISPLAY_NUM"
  '';
  newWsScript = pkgs.writeShellScript "new-workspace" ''
    MONITOR="$1"
    MONITORS=$(hyprctl monitors -j)
    MON_IDX=$(echo "$MONITORS" | ${jq} --arg mon "$MONITOR" \
      '[sort_by([.x, .y]) | .[].name] | index($mon)')
    BASE=$((MON_IDX * ${toString wsPerMonitor} + 1))
    TOP=$((BASE + ${toString wsPerMonitor} - 1))
    MAX_WS=$(hyprctl workspaces -j | ${jq} --argjson base "$BASE" --argjson top "$TOP" \
      '[.[] | select(.id >= $base and .id <= $top) | .id] | if length > 0 then max else ($base - 1) end')
    NEXT=$((MAX_WS + 1))
    hyprctl --batch "dispatch hl.dsp.focus({ monitor = \"$MONITOR\" }) ; dispatch hl.dsp.focus({ workspace = $NEXT })"
  '';
  script = pkgs.writeShellScript "workspaces" ''
    MONITORS=$(hyprctl monitors -j)
    WORKSPACES=$(hyprctl workspaces -j)
    echo "$WORKSPACES" | ${jq} -c \
      --argjson m "$MONITORS" \
      --argjson wsPerMonitor ${toString wsPerMonitor} \
      '([$m | sort_by([.x, .y]) | .[].name]) as $sorted_monitors |
        [group_by(.monitor) | .[] |
          . as $g |
          ([$m[] | select(.name == $g[0].monitor)][0]) as $mon |
          ($sorted_monitors | index($mon.name)) as $mon_idx |
          (($mon_idx * $wsPerMonitor) + 1) as $base |
          ($base + $wsPerMonitor - 1) as $top |
          {
            monitor: ($mon.name // $g[0].monitor),
            activeWorkspace: ($mon.activeWorkspace.id // 0),
            workspaces: [$g[] | select(.id >= $base and .id <= $top) | {id: .id, windows: .windows}] | sort_by(.id)
          }
        ] | sort_by(.monitor)'
  '';
in
{
  inherit script;

  yuck = ''
    (deflisten monitors-data
      :initial "[]"
      "${script}; socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r _line; do ${script}; done")

    (defwidget workspaces []
      (box
        :class "workspaces module"
        :orientation "h"
        :spacing 2
        :space-evenly true
        (for mon in monitors-data
          (box
            :class "workspace-col"
            :orientation "v"
            :spacing 2
            :space-evenly false
            (box
              :orientation "v"
              :spacing 2
              :space-evenly false
              :vexpand false
              (for ws in {mon.workspaces}
              (button
                :class {ws.id == mon.activeWorkspace ? "workspace active"
                        : (ws.windows > 0 ? "workspace occupied" : "workspace empty")}
                :onclick {"${switchWsScript} " + ws.id + " " + mon.monitor}
                :onmiddleclick {"${closeWsScript} " + ws.id}
                :valign "center"
                :vexpand false
                {ws.id == mon.activeWorkspace ? "${ws.active}" : (ws.windows > 0 ? "${ws.occupied}" : "${ws.empty}")}
              )))
            (button
              :class "workspace new"
              :onclick {"${newWsScript} " + mon.monitor}
              :valign "center"
              :vexpand false
              "${ws.empty}")
          ))))
  '';

  scss = ''
    button.workspace {
      background: transparent;
      border: none;
      padding: 1px 0;
      margin: 0;
      color: $fg-faint;
    }

    button.workspace.active {
      color: $accent;
    }

    button.workspace.occupied {
      color: $fg-dim;
    }

    button.workspace.new {
      opacity: 0.4;
    }

    button.workspace.new:hover {
      opacity: 1;
      color: $accent;
    }
  '';
}
