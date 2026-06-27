{ pkgs, icons }:

let
  ws = icons.workspace;
  script = pkgs.writeShellScript "workspaces" ''
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
  inherit script;

  yuck = ''
    (deflisten monitors-data
      :initial "[]"
      "${script}; socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r _line; do ${script}; done")

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
            (box
              :orientation "v"
              :spacing 4
              :space-evenly false
              :vexpand false
              (for ws in {mon.workspaces}
              (button
                :class {ws.id == mon.activeWorkspace ? "workspace active"
                        : (ws.windows > 0 ? "workspace occupied" : "workspace empty")}
                :onclick "hyprctl dispatch 'hl.dsp.focus({ workspace = \"''${ws.id}\" })'"
                :valign "center"
                :vexpand false
                {ws.id == mon.activeWorkspace ? "${ws.active}" : (ws.windows > 0 ? "${ws.occupied}" : "${ws.empty}")}
              )))
            (button
              :class "workspace new"
              :onclick {"hyprctl dispatch focusmonitor " + mon.monitor + " && hyprctl dispatch workspace emptynm"}
              :valign "center"
              :vexpand false
              "${ws.empty}")
          ))))
  '';

  scss = ''
    button.workspace {
      background: transparent;
      border: none;
      padding: 2px 0;
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
