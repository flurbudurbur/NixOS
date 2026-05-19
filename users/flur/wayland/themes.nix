{ pkgs, lib, nixpkgs-unstable, ... }:

let
  themes = import ../../../modules/themes/default.nix;

  strip = hex: builtins.substring 1 6 hex;
  hyprColor = hex: alpha: "rgba(${strip hex}${alpha})";


  mkHyprTheme = t: ''
    general {
      col.active_border = ${hyprColor t.accent "ee"} ${hyprColor t.accent2 "aa"} 45deg
      col.inactive_border = ${hyprColor t.bg_select "aa"}
    }
    decoration {
      shadow {
        color = ${hyprColor t.bg "ee"}
        color_inactive = ${hyprColor t.bg "88"}
      }
    }
  '';

  starshipBase = builtins.readFile ../shell/starship.toml;

  mkStarshipTheme = t: starshipBase + ''

    [palettes.theme]
    overlay = '${t.bg_select}'
    love = '${t.error}'
    gold = '${t.warning}'
    rose = '${t.accent2}'
    pine = '${t.blue}'
    foam = '${t.cyan}'
    iris = '${t.accent}'
  '';

  hexToRgb =
    hex:
    let
      hexToInt =
        h:
        let
          chars = {
            "0" = 0; "1" = 1; "2" = 2; "3" = 3; "4" = 4;
            "5" = 5; "6" = 6; "7" = 7; "8" = 8; "9" = 9;
            "a" = 10; "b" = 11; "c" = 12; "d" = 13; "e" = 14; "f" = 15;
          };
          c1 = builtins.substring 0 1 h;
          c2 = builtins.substring 1 1 h;
        in
        chars.${c1} * 16 + chars.${c2};
      r = hexToInt (builtins.substring 1 2 hex);
      g = hexToInt (builtins.substring 3 2 hex);
      b = hexToInt (builtins.substring 5 2 hex);
    in
    "${toString r}, ${toString g}, ${toString b}";

  mkWaybarTheme =
    t:
    let
      rgba = hex: alpha: "rgba(${hexToRgb hex}, ${alpha})";
    in
    ''
      * {
        font-family: "Bricolage Grotesque", sans-serif;
        font-size: 13px;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        background-color: transparent;
      }

      .modules-left, .modules-center, .modules-right {
        background-color: ${rgba t.bg "0.9"};
        border-radius: 10px;
        margin-top: 10px;
        margin-left: 10px;
        margin-right: 10px;
        margin-bottom: 0;
        padding: 0 10px;
        transition: all 0.3s ease-in-out;
      }

      #workspaces button {
        padding: 0 5px;
        color: ${t.fg};
        background: transparent;
        border: none;
        min-width: 20px;
      }

      #workspaces button.active {
        color: ${t.accent2};
        background: ${rgba t.accent2 "0.2"};
        border: none;
      }

      #workspaces button:hover {
        background: ${rgba t.accent2 "0.1"};
      }

      #window {
        color: ${t.fg};
      }

      #mpris {
        color: ${t.accent2};
      }

      #mpris.paused {
        color: ${t.fg_faint};
      }

      #clock {
        color: ${t.accent};
      }

      #cpu {
        color: ${t.error};
      }

      #memory {
        color: ${t.warning};
      }

      #network {
        color: ${t.cyan};
      }

      #wireplumber {
        color: ${t.blue};
      }

      #bluetooth {
        color: ${t.accent};
      }

      #bluetooth.disabled,
      #bluetooth.off {
        color: ${t.fg_faint};
      }

      #tray {
        color: ${t.fg};
      }

      #clock, #cpu, #memory, #network, #wireplumber, #bluetooth, #tray, #window, #mpris {
        padding: 0 10px;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }
    '';

  mkFootTheme = t: ''
    [colors]
    alpha=0.95
    background=${strip t.bg}
    foreground=${strip t.fg}
    selection-background=${strip t.bg_select}
    selection-foreground=${strip t.fg}
    urls=${strip t.blue}
    regular0=${strip t.bg_select}
    regular1=${strip t.error}
    regular2=${strip t.blue}
    regular3=${strip t.warning}
    regular4=${strip t.cyan}
    regular5=${strip t.accent}
    regular6=${strip t.accent2}
    regular7=${strip t.fg}
    bright0=${strip t.fg_faint}
    bright1=${strip t.error}
    bright2=${strip t.blue}
    bright3=${strip t.warning}
    bright4=${strip t.cyan}
    bright5=${strip t.accent}
    bright6=${strip t.accent2}
    bright7=${strip t.fg}

    [cursor]
    color=${strip t.bg} ${strip t.accent}
  '';

  mkWalkerTheme =
    t:
    let
      rgba = hex: alpha: "rgba(${hexToRgb hex}, ${alpha})";
    in
    ''
      * {
        color: ${t.fg};
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 14px;
      }

      .window {
        background: transparent;
      }

      .box-wrapper {
        background: ${rgba t.bg "0.95"};
        border-radius: 10px;
        border: 2px solid ${rgba t.blue "0.3"};
        padding: 10px;
      }

      .input {
        background: ${rgba t.bg_alt "0.8"};
        color: ${t.fg};
        border: 1px solid ${rgba t.bg_select "0.5"};
        border-radius: 8px;
        padding: 8px 12px;
        margin-bottom: 10px;
      }

      .input:focus {
        border-color: ${t.blue};
        box-shadow: 0 0 0 2px ${rgba t.blue "0.3"};
      }

      .item {
        background: transparent;
        border-radius: 6px;
        padding: 8px 12px;
        margin: 2px 0;
      }

      .item:hover {
        background: ${rgba t.bg_select "0.5"};
      }

      .item:selected {
        background: ${rgba t.blue "0.3"};
        border: 1px solid ${t.blue};
      }

      .item-text {
        color: ${t.fg};
      }

      .item-sub {
        color: ${t.fg_dim};
        font-size: 12px;
      }

      .item-icon {
        margin-right: 10px;
      }

      scrollbar {
        background: ${rgba t.bg_alt "0.3"};
        border-radius: 10px;
      }

      scrollbar slider {
        background: ${rgba t.fg_faint "0.5"};
        border-radius: 10px;
      }

      scrollbar slider:hover {
        background: ${rgba t.blue "0.6"};
      }
    '';

  mkHyprLockTheme = t: ''
    input-field {
      size = 200, 50
      position = 0, -80
      monitor =
      dots_center = true
      fade_on_empty = false
      font_color = rgb(${hexToRgb t.fg})
      inner_color = rgb(${hexToRgb t.bg_select})
      outer_color = rgb(${hexToRgb t.bg})
      outline_thickness = 5
      placeholder_text = <span foreground="##${strip t.fg}">Password...</span>
      shadow_passes = 2
    }

    label {
      monitor =
      text = cmd[update:1000] echo "<span>$(date +"%H:%M")</span>"
      color = rgb(${hexToRgb t.fg})
      font_size = 120
      font_family = JetBrains Mono
      position = 0, 200
      halign = center
      valign = center
    }

    label {
      monitor =
      text = cmd[update:1000] echo "<span>$(date +"%A, %B %d")</span>"
      color = rgb(${hexToRgb t.fg})
      font_size = 20
      font_family = JetBrains Mono
      position = 0, 100
      halign = center
      valign = center
    }
  '';

  mkBase16Yaml = name: t: ''
    scheme: "${name}"
    author: "flur"
    base00: "${strip t.bg}"
    base01: "${strip t.bg_alt}"
    base02: "${strip t.bg_select}"
    base03: "${strip t.fg_faint}"
    base04: "${strip t.fg_dim}"
    base05: "${strip t.fg}"
    base06: "${strip t.fg}"
    base07: "${strip t.fg}"
    base08: "${strip t.error}"
    base09: "${strip t.warning}"
    base0A: "${strip t.warning}"
    base0B: "${strip t.cyan}"
    base0C: "${strip t.cyan}"
    base0D: "${strip t.blue}"
    base0E: "${strip t.accent}"
    base0F: "${strip t.accent2}"
  '';

  mkBase16Attrs = name: t: {
    scheme = name;
    author = "flur";
    base00 = strip t.bg;
    base01 = strip t.bg_alt;
    base02 = strip t.bg_select;
    base03 = strip t.fg_faint;
    base04 = strip t.fg_dim;
    base05 = strip t.fg;
    base06 = strip t.fg;
    base07 = strip t.fg;
    base08 = strip t.error;
    base09 = strip t.warning;
    base0A = strip t.warning;
    base0B = strip t.cyan;
    base0C = strip t.cyan;
    base0D = strip t.blue;
    base0E = strip t.accent;
    base0F = strip t.accent2;
  };

  schemes = lib.mapAttrs (name: t:
    pkgs.writeText "${name}.yaml" (mkBase16Yaml name t)
  ) themes;

  mkThemeFiles = name: t:
    let
      wallpaperExts = [ "jpg" "png" "webp" "gif" ];
      wallpaperExt = lib.findFirst
        (ext: builtins.pathExists (../../../wallpapers + "/${name}.${ext}"))
        null
        wallpaperExts;
      wallpaperEntry = lib.optionalAttrs (wallpaperExt != null) {
        "themes/${name}/wallpaper".source =
          ../../../wallpapers + "/${name}.${wallpaperExt}";
      };
    in
    {
      "themes/${name}/hyprland.conf".text = mkHyprTheme t;
      "themes/${name}/starship.toml".text = mkStarshipTheme t;
      "themes/${name}/waybar-style.css".text = mkWaybarTheme t;
      "themes/${name}/foot-colors.ini".text = mkFootTheme t;
      "themes/${name}/walker-style.css".text = mkWalkerTheme t;
      "themes/${name}/hyprlock.conf".text = mkHyprLockTheme t;
      "themes/${name}/scheme.yaml".source = schemes.${name};
    } // wallpaperEntry;

  themeFiles = lib.foldlAttrs (acc: name: t: acc // mkThemeFiles name t) { } themes;

  themeNames = builtins.attrNames themes;

  oscCases = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: t: ''
    ${name})
      printf '\033]4;0;${t.bg_select}\007\033]4;1;${t.error}\007\033]4;2;${t.blue}\007\033]4;3;${t.warning}\007\033]4;4;${t.cyan}\007\033]4;5;${t.accent}\007\033]4;6;${t.accent2}\007\033]4;7;${t.fg}\007\033]4;8;${t.fg_faint}\007\033]4;9;${t.error}\007\033]4;10;${t.blue}\007\033]4;11;${t.warning}\007\033]4;12;${t.cyan}\007\033]4;13;${t.accent}\007\033]4;14;${t.accent2}\007\033]4;15;${t.fg}\007\033]10;${t.fg}\007\033]11;${t.bg}\007\033]12;${t.accent}\007' > "''${_pts}" 2>/dev/null || true
      ;;
  '') themes);

  switchScript = pkgs.writeShellScriptBin "theme-switch" ''
    set -euo pipefail
    THEMES_DIR="$HOME/.config/themes"
    THEME="''${1:-}"

    if [ -z "$THEME" ]; then
      CURRENT=$(basename "$(readlink "$THEMES_DIR/current")")
      AVAILABLE=(${lib.concatStringsSep " " themeNames})
      CURRENT_IDX=-1
      for i in "''${!AVAILABLE[@]}"; do
        if [ "''${AVAILABLE[$i]}" = "$CURRENT" ]; then
          CURRENT_IDX=$i
          break
        fi
      done
      NEXT_IDX=$(( (CURRENT_IDX + 1) % ''${#AVAILABLE[@]} ))
      THEME="''${AVAILABLE[$NEXT_IDX]}"
    fi

    if [ ! -d "$THEMES_DIR/$THEME" ]; then
      echo "Theme '$THEME' not found. Available themes:"
      printf '  %s\n' ${lib.concatStringsSep " " themeNames}
      exit 1
    fi

    ln -sfT "$THEMES_DIR/$THEME" "$THEMES_DIR/current"

    _wp="$THEMES_DIR/$THEME/wallpaper"
    if [ -f "$_wp" ]; then
      awww img "$_wp" \
        --transition-type any \
        --transition-duration 1.5 \
        --transition-fps 30 2>/dev/null || true
    fi

    hyprctl reload
    pkill -SIGUSR2 waybar
    systemctl --user restart walker 2>/dev/null || true

    _foot_update() {
      local _pts="$1"
      case "$THEME" in
        ${oscCases}
        *)
          ;;
      esac
    }
    for _foot_pid in $(pgrep -x foot 2>/dev/null); do
      for _child_pid in $(pgrep -P "$_foot_pid" 2>/dev/null); do
        _pts=$(readlink "/proc/$_child_pid/fd/1" 2>/dev/null) || continue
        [[ "$_pts" == /dev/pts/* ]] || continue
        _foot_update "$_pts"
      done
    done

    tmux refresh-client 2>/dev/null || true

    echo "Switched to theme: $THEME"
  '';
in
{
  xdg.configFile = themeFiles;

  stylix.base16Scheme = mkBase16Attrs "rose-pine-moon" themes."rose-pine-moon";

  home.packages = [ switchScript nixpkgs-unstable.awww ];

  home.activation.initTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    THEMES_DIR="$HOME/.config/themes"
    if [ ! -L "$THEMES_DIR/current" ]; then
      $DRY_RUN_CMD ln -sfT "$THEMES_DIR/rose-pine-moon" "$THEMES_DIR/current"
    fi
  '';
}
