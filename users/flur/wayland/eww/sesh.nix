{ pkgs }:

# Icons are the exact codepoints sesh uses with --icons:
#   U+EBC8 (60360) = tmux session
#   U+EBEB (60395) = tmuxinator config
#   U+F114 (61716) = zoxide folder
let
  listScript = pkgs.writeShellScript "sesh-list" ''
    ${pkgs.sesh}/bin/sesh list --json -d | ${pkgs.jq}/bin/jq '[
      .[] |
      select(.Src != "zoxide" or .Score >= 2) |
      {
        name: .Name,
        src: .Src,
        attached: .Attached,
        icon: (
          if .Src == "tmux" then ([60360] | implode)
          elif .Src == "tmuxinator" then ([60395] | implode)
          else ([61716] | implode)
          end
        )
      }
    ] | sort_by([
      if .src == "tmux" then 0 elif .src == "tmuxinator" then 1 else 2 end,
      .name
    ])'
  '';

  # Shared close logic: close popup and remove the Escape bind
  closeScript = pkgs.writeShellScript "sesh-close" ''
    ${pkgs.eww}/bin/eww close sesh-popup 2>/dev/null || true
    hyprctl keyword unbind ", escape"
  '';

  connectScript = pkgs.writeShellScript "sesh-connect" ''
    NAME="$1"
    SRC="$2"
    ${closeScript}
    if [ "$SRC" = "tmux" ]; then
      ${pkgs.sesh}/bin/sesh connect --switch "$NAME"
    else
      ${pkgs.foot}/bin/foot -e ${pkgs.sesh}/bin/sesh connect "$NAME" &
    fi
  '';

  toggleScript = pkgs.writeShellScript "sesh-toggle" ''
    if ${pkgs.eww}/bin/eww active-windows 2>/dev/null | grep -q "sesh-popup"; then
      ${closeScript}
    else
      DATA=$(${listScript})
      ${pkgs.eww}/bin/eww update "sesh-data=$DATA"
      ${pkgs.eww}/bin/eww open sesh-popup
      hyprctl keyword bind ", escape, exec, ${closeScript}"
    fi
  '';
in
{
  inherit listScript connectScript toggleScript;

  yuck = ''
    (defvar sesh-data "[]")

    (defwidget sesh-list []
      (box
        :class "sesh-win"
        :orientation "v"
        :space-evenly false
        (box
          :class "sesh-titlebar"
          :orientation "h"
          :space-evenly false
          :spacing 8
          (label :class "sesh-dot sesh-dot-red"    :text "●")
          (label :class "sesh-dot sesh-dot-yellow" :text "●")
          (label :class "sesh-dot sesh-dot-green"  :text "●")
          (label :class "sesh-title" :text " sesh" :hexpand true :halign "center"))
        (box
          :class "sesh-body"
          :orientation "v"
          :space-evenly false
          :spacing 0
          (for item in sesh-data
            (button
              :class {"sesh-item sesh-" + item.src}
              :onclick {"${connectScript} \"" + item.name + "\" " + item.src}
              (box
                :orientation "h"
                :spacing 10
                :halign "fill"
                (label :class "sesh-icon" :text {item.icon})
                (label
                  :class "sesh-name"
                  :text {item.name}
                  :truncate true
                  :hexpand true
                  :halign "start")))))))

    (defwindow sesh-popup
      :monitor "DP-1"
      :geometry (geometry
        :x "0px"
        :y "0px"
        :width "768px"
        :height "500px")
      :anchor "center"
      :stacking "overlay"
      :focusable true
      (sesh-list))
  '';

  scss = ''
    .sesh-win {
      font-family: "MapleMono NF", monospace;
      background: $bg;
      border-radius: 8px;
      border: 1px solid $bg-select;
    }

    .sesh-titlebar {
      background: $bg-alt;
      border-radius: 8px 8px 0 0;
      padding: 8px 14px;
      border-bottom: 1px solid $bg-select;
    }

    .sesh-dot {
      font-size: 10px;
    }

    .sesh-dot-red    { color: $error; }
    .sesh-dot-yellow { color: $warning; }
    .sesh-dot-green  { color: $accent; }

    .sesh-title {
      font-family: "MapleMono NF", monospace;
      font-size: 12px;
      color: $fg-faint;
    }

    .sesh-body {
      padding: 6px 2px;
    }

    .sesh-item {
      font-family: "MapleMono NF", monospace;
      background: transparent;
      border-radius: 4px;
      padding: 4px 14px;
      min-width: 0;
    }

    .sesh-item:hover {
      background: $bg-select;
    }

    .sesh-icon {
      font-size: 14px;
      min-width: 22px;
    }

    .sesh-name {
      font-family: "MapleMono NF", monospace;
      font-size: 13px;
    }

    .sesh-item.sesh-tmux .sesh-icon        { color: $blue; }
    .sesh-item.sesh-tmuxinator .sesh-icon  { color: $warning; }
    .sesh-item.sesh-zoxide .sesh-icon      { color: $cyan; }

    .sesh-item.sesh-tmux .sesh-name        { color: $fg; }
    .sesh-item.sesh-tmuxinator .sesh-name  { color: $fg-dim; }
    .sesh-item.sesh-zoxide .sesh-name      { color: $fg-faint; }
  '';
}
