{
  pkgs,
  lib,
  nixpkgs-unstable,
  tinted-schemes,
  ...
}:

let
  themes = import ../../../modules/themes/default.nix { schemes = tinted-schemes; };

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

  mkHyprThemeLua = t: ''
    hl.config({
      general = {
        col = {
          active_border   = { colors = {"rgba(${strip t.accent}ee)", "rgba(${strip t.accent2}aa)"}, angle = 45 },
          inactive_border = "rgba(${strip t.bg_select}aa)",
        },
      },
      decoration = {
        shadow = {
          color          = "rgba(${strip t.bg}ee)",
          color_inactive = "rgba(${strip t.bg}88)",
        },
      },
    })
  '';

  starshipBase = builtins.readFile ../../../dotfiles/starship.toml;

  mkStarshipTheme =
    t:
    starshipBase
    + ''

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
            "0" = 0;
            "1" = 1;
            "2" = 2;
            "3" = 3;
            "4" = 4;
            "5" = 5;
            "6" = 6;
            "7" = 7;
            "8" = 8;
            "9" = 9;
            "a" = 10;
            "b" = 11;
            "c" = 12;
            "d" = 13;
            "e" = 14;
            "f" = 15;
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

  mkBarTheme =
    t:
    let
      rgba = hex: alpha: "rgba(${hexToRgb hex}, ${alpha})";
    in
    ''
      $bg: ${t.bg};
      $bg-alpha: ${rgba t.bg "0.9"};
      $bg-alt: ${t.bg_alt};
      $bg-select: ${t.bg_select};
      $fg: ${t.fg};
      $fg-faint: ${t.fg_faint};
      $fg-dim: ${t.fg_dim};
      $accent: ${t.accent};
      $accent2: ${t.accent2};
      $blue: ${t.blue};
      $cyan: ${t.cyan};
      $error: ${t.error};
      $warning: ${t.warning};
    '';

  mkFootTheme = t: ''
    [colors-dark]
    alpha=1
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
    cursor=${strip t.bg} ${strip t.accent}
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
      check_color = rgb(${hexToRgb t.accent})
      fail_color = rgb(${hexToRgb t.error})
      fail_text = <span foreground="##${strip t.error}">$FAIL <b>($ATTEMPTS)</b></span>
      capslock_color = rgb(${hexToRgb t.warning})
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

  mkZenTheme = t: ''
    :root {
      --zen-colors-primary: ${t.bg_select} !important;
      --zen-primary-color: ${t.blue} !important;
      --zen-colors-secondary: ${t.bg_select} !important;
      --zen-colors-tertiary: ${t.bg_alt} !important;
      --zen-colors-border: ${t.blue} !important;
      --toolbarbutton-icon-fill: ${t.blue} !important;
      --lwt-text-color: ${t.fg} !important;
      --toolbar-field-color: ${t.fg} !important;
      --tab-selected-textcolor: ${t.fg} !important;
      --toolbar-field-focus-color: ${t.fg} !important;
      --toolbar-color: ${t.fg} !important;
      --newtab-text-primary-color: ${t.fg} !important;
      --arrowpanel-color: ${t.fg} !important;
      --arrowpanel-background: ${t.bg} !important;
      --sidebar-text-color: ${t.fg} !important;
      --lwt-sidebar-text-color: ${t.fg} !important;
      --lwt-sidebar-background-color: ${t.bg} !important;
      --toolbar-bgcolor: ${t.bg_select} !important;
      --newtab-background-color: ${t.bg} !important;
      --zen-themed-toolbar-bg: ${t.bg} !important;
      --zen-main-browser-background: ${t.bg} !important;
      --toolbox-bgcolor-inactive: ${t.bg_alt} !important;
      --zen-themed-toolbar-bg-transparent: ${t.bg_alt} !important;
    }

    #permissions-granted-icon {
      color: ${t.fg} !important;
    }

    #historySwipeAnimationPreviousArrow,#historySwipeAnimationNextArrow {
      --swipe-nav-icon-primary-color: ${t.blue} !important;
      --swipe-nav-icon-accent-color: ${t.bg} !important;
    }

    .sidebar-placesTree {
      background-color: ${t.bg} !important;
    }

    #zen-workspaces-button {
      background-color: ${t.bg} !important;
    }

    #TabsToolbar {
      background-color: ${t.bg} !important;
    }

    .urlbar-background {
      background-color: ${t.bg_select} !important;
    }

    .content-shortcuts {
      background-color: ${t.bg} !important;
      border-color: ${t.blue} !important;
    }

    .urlbarView-url {
      color: ${t.blue} !important;
    }

    #urlbar-input::selection {
      background-color: ${t.blue} !important;
      color: ${t.bg} !important;
    }

    #zenEditBookmarkPanelFaviconContainer {
      background: ${t.bg} !important;
    }

    #zen-media-controls-toolbar {
      & #zen-media-progress-bar {
        &::-moz-range-track {
          background: ${t.bg_select} !important;
        }
      }
    }

    toolbar .toolbarbutton-1 {
      &:not([disabled]) {
        &:is([open], [checked])
          > :is(
            .toolbarbutton-icon,
            .toolbarbutton-text,
            .toolbarbutton-badge-stack
          ) {
          fill: ${t.bg};
        }
      }
    }

    .identity-color-blue {
      --identity-tab-color: ${t.blue} !important;
      --identity-icon-color: ${t.blue} !important;
    }

    .identity-color-turquoise {
      --identity-tab-color: ${t.cyan} !important;
      --identity-icon-color: ${t.cyan} !important;
    }

    .identity-color-green {
      --identity-tab-color: ${t.cyan} !important;
      --identity-icon-color: ${t.cyan} !important;
    }

    .identity-color-yellow {
      --identity-tab-color: ${t.warning} !important;
      --identity-icon-color: ${t.warning} !important;
    }

    .identity-color-orange {
      --identity-tab-color: ${t.warning} !important;
      --identity-icon-color: ${t.warning} !important;
    }

    .identity-color-red {
      --identity-tab-color: ${t.error} !important;
      --identity-icon-color: ${t.error} !important;
    }

    .identity-color-pink {
      --identity-tab-color: ${t.accent} !important;
      --identity-icon-color: ${t.accent} !important;
    }

    .identity-color-purple {
      --identity-tab-color: ${t.accent2} !important;
      --identity-icon-color: ${t.accent2} !important;
    }

    #zen-toolbar-background {
      --zen-main-browser-background-toolbar: ${t.bg} !important;
    }

    #zen-appcontent-navbar-container {
      background-color: ${t.bg} !important;
    }

    #commonDialog {
      background-color: ${t.bg} !important;
    }

    #zen-browser-background {
      --zen-main-browser-background: ${t.bg} !important;
    }

    #contentAreaContextMenu menu,
    menuitem,
    menupopup {
      color: ${t.fg} !important;
    }
  '';

  mkNvimTheme = t: ''
    require('mini.base16').setup({
      palette = {
        base00 = '${t.bg}',
        base01 = '${t.bg_alt}',
        base02 = '${t.bg_select}',
        base03 = '${t.fg_faint}',
        base04 = '${t.fg_dim}',
        base05 = '${t.fg}',
        base06 = '${t.fg}',
        base07 = '${t.fg}',
        base08 = '${t.error}',
        base09 = '${t.warning}',
        base0A = '${t.warning}',
        base0B = '${t.cyan}',
        base0C = '${t.cyan}',
        base0D = '${t.blue}',
        base0E = '${t.accent}',
        base0F = '${t.accent2}',
      }
    })
  '';

  mkMakoTheme = t: ''
    background-color=${t.bg}
    text-color=${t.fg}
    border-color=${t.blue}
    progress-color=${t.cyan}

    [urgency=low]
    border-color=${t.fg_dim}

    [urgency=normal]
    border-color=${t.blue}

    [urgency=critical]
    border-color=${t.error}
    default-timeout=0
  '';

  mkGtkCss = t: ''
    @define-color accent_color ${t.blue};
    @define-color accent_bg_color ${t.blue};
    @define-color accent_fg_color ${t.fg};
    @define-color warning_color ${t.warning};
    @define-color error_color ${t.error};
    @define-color success_color ${t.cyan};
    @define-color theme_bg_color ${t.bg};
    @define-color theme_fg_color ${t.fg};
    @define-color theme_base_color ${t.bg_alt};
    @define-color theme_text_color ${t.fg};
    @define-color theme_selected_bg_color ${t.blue};
    @define-color theme_selected_fg_color ${t.fg};
    @define-color insensitive_bg_color ${t.bg_select};
    @define-color insensitive_fg_color ${t.fg_faint};
    @define-color borders ${t.bg_select};
    @define-color destructive_color ${t.error};
    @define-color destructive_bg_color ${t.error};
    @define-color destructive_fg_color ${t.fg};
    @define-color success_bg_color ${t.cyan};
    @define-color success_fg_color ${t.bg};
    @define-color warning_bg_color ${t.warning};
    @define-color warning_fg_color ${t.bg};
    @define-color error_bg_color ${t.error};
    @define-color error_fg_color ${t.fg};
    @define-color window_bg_color ${t.bg};
    @define-color window_fg_color ${t.fg};
    @define-color view_bg_color ${t.bg_alt};
    @define-color view_fg_color ${t.fg};
    @define-color card_bg_color ${t.bg_alt};
    @define-color card_fg_color ${t.fg};
    @define-color popover_bg_color ${t.bg_alt};
    @define-color popover_fg_color ${t.fg};
    @define-color sidebar_bg_color ${t.bg};
    @define-color sidebar_fg_color ${t.fg};
    @define-color headerbar_bg_color ${t.bg};
    @define-color headerbar_fg_color ${t.fg};
    @define-color dialog_bg_color ${t.bg_alt};
    @define-color dialog_fg_color ${t.fg};
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

  schemes = lib.mapAttrs (name: t: pkgs.writeText "${name}.yaml" (mkBase16Yaml name t)) themes;

  mkThemeFiles =
    name: t:
    let
      wallpaperExts = [
        "jpg"
        "png"
        "webp"
        "gif"
      ];
      wallpaperExt = lib.findFirst (
        ext: builtins.pathExists (../../../wallpapers + "/${name}.${ext}")
      ) null wallpaperExts;
      wallpaperEntry = lib.optionalAttrs (wallpaperExt != null) {
        "themes/${name}/wallpaper".source = ../../../wallpapers + "/${name}.${wallpaperExt}";
      };
    in
    {
      "themes/${name}/hyprland.conf".text = mkHyprTheme t;
      "themes/${name}/hyprland.lua".text = mkHyprThemeLua t;
      "themes/${name}/starship.toml".text = mkStarshipTheme t;
      "themes/${name}/foot-colors.ini".text = mkFootTheme t;
      "themes/${name}/walker-style.css".text = mkWalkerTheme t;
      "themes/${name}/hyprlock.conf".text = mkHyprLockTheme t;
      "themes/${name}/scheme.yaml".source = schemes.${name};
      "themes/${name}/zen-userchrome.css".text = mkZenTheme t;
      "themes/${name}/nvim-theme.lua".text = mkNvimTheme t;
      "themes/${name}/mako.conf".text = mkMakoTheme t;
      "themes/${name}/gtk.css".text = mkGtkCss t;
      "themes/${name}/bar.scss".text = mkBarTheme t;
    }
    // wallpaperEntry;

  themeFiles = lib.foldlAttrs (
    acc: name: t:
    acc // mkThemeFiles name t
  ) { } themes;

  themeNames = builtins.attrNames themes;

  oscCases = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: t: ''
      ${name})
        printf '\033]4;0;${t.bg_select}\007\033]4;1;${t.error}\007\033]4;2;${t.blue}\007\033]4;3;${t.warning}\007\033]4;4;${t.cyan}\007\033]4;5;${t.accent}\007\033]4;6;${t.accent2}\007\033]4;7;${t.fg}\007\033]4;8;${t.fg_faint}\007\033]4;9;${t.error}\007\033]4;10;${t.blue}\007\033]4;11;${t.warning}\007\033]4;12;${t.cyan}\007\033]4;13;${t.accent}\007\033]4;14;${t.accent2}\007\033]4;15;${t.fg}\007\033]10;${t.fg}\007\033]11;${t.bg}\007\033]12;${t.accent}\007' > "''${_pts}" 2>/dev/null || true
        ;;
    '') themes
  );

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
    makoctl reload 2>/dev/null || true
    ${pkgs.eww}/bin/eww reload 2>/dev/null || true
    systemctl --user restart walker 2>/dev/null || true

    ZEN_CHROME="$HOME/.config/zen/default/chrome"
    if [ -d "$ZEN_CHROME" ]; then
      ln -sf "$THEMES_DIR/$THEME/zen-userchrome.css" "$ZEN_CHROME/userChrome.css"
      if pgrep -x zen-beta > /dev/null 2>&1; then
        pkill -x zen-beta || true
        sleep 0.3
        zen-beta &
        disown
      fi
    fi

    pkill -SIGUSR1 foot 2>/dev/null || true

    for _pts in /dev/pts/[0-9]*; do
      [ -w "$_pts" ] || continue
      case "$THEME" in
        ${oscCases}
      esac
    done

    for _sock in $(find "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" -maxdepth 1 -name 'nvim*' -type s 2>/dev/null || true); do
      nvim --server "$_sock" --remote-send ':source ~/.config/themes/current/nvim-theme.lua<CR>' 2>/dev/null || true
    done

    gsettings set org.gnome.desktop.interface color-scheme 'default' 2>/dev/null || true
    sleep 0.1
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true

    tmux refresh-client 2>/dev/null || true

    notify-send -a "Theme Switcher" "Switched to $THEME" -i preferences-desktop-theme 2>/dev/null || true
  '';
in
{
  xdg.configFile = themeFiles;

  stylix.base16Scheme = mkBase16Attrs "rose-pine-moon" themes."rose-pine-moon";

  home.packages = [
    switchScript
    nixpkgs-unstable.awww
  ];

  systemd.user.services.awww = {
    Unit = {
      Description = "An Answer to your Wayland Wallpaper Woes";
      Documentation = "man:awww-daemon(1)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${nixpkgs-unstable.awww}/bin/awww-daemon";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  home.activation.initTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    THEMES_DIR="$HOME/.config/themes"
    if [ ! -L "$THEMES_DIR/current" ]; then
      $DRY_RUN_CMD ln -sfT "$THEMES_DIR/rose-pine-moon" "$THEMES_DIR/current"
    fi

    CURRENT_THEME=$(basename "$(readlink "$THEMES_DIR/current" 2>/dev/null || echo rose-pine-moon)")
    ZEN_CHROME="$HOME/.config/zen/default/chrome"
    if [ -d "$ZEN_CHROME" ] && [ -f "$THEMES_DIR/$CURRENT_THEME/zen-userchrome.css" ]; then
      $DRY_RUN_CMD ln -sf "$THEMES_DIR/$CURRENT_THEME/zen-userchrome.css" "$ZEN_CHROME/userChrome.css"
    fi
  '';
}
