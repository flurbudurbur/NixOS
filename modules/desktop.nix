{
  pkgs,
  lib,
  tinted-schemes,
  ...
}:
let
  themes = import ./themes/default.nix { schemes = tinted-schemes; };

  wallpaperFor =
    name:
    let
      candidates = builtins.filter builtins.pathExists (
        map (ext: ../wallpapers + "/${name}.${ext}") [
          "jpg"
          "png"
          "webp"
          "gif"
        ]
      );
    in
    if candidates == [ ] then null else builtins.head candidates;

  manifestFor =
    name: colors:
    pkgs.writeText "noctalia-greeter-${name}.json" (
      builtins.toJSON (
        {
          version = 1;
          theme_mode = "dark";
          palette = {
            primary = colors.accent2;
            on_primary = colors.bg;
            secondary = colors.cyan;
            on_secondary = colors.bg;
            tertiary = colors.blue;
            on_tertiary = colors.bg;
            inherit (colors) error;
            on_error = colors.bg;
            surface = colors.bg;
            on_surface = colors.fg;
            surface_variant = colors.bg_select;
            on_surface_variant = colors.fg_dim;
            outline = colors.hl_med;
            shadow = colors.bg;
            hover = colors.hl_high;
            on_hover = colors.fg;
          };
        }
        // lib.optionalAttrs (wallpaperFor name != null) {
          wallpaper = {
            path = "${wallpaperFor name}";
            fill_mode = "crop";
          };
        }
      )
    );

  appearanceManifests = pkgs.linkFarm "noctalia-greeter-appearance-manifests" (
    lib.mapAttrsToList (name: colors: {
      name = "${name}.json";
      path = manifestFor name colors;
    }) themes
  );
in
{
  # Hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Greeter for greetd (enables greetd itself)
  programs.noctalia-greeter = {
    enable = true;
    settings = {
      appearance = {
        scheme = "Synced";
        hide_logo = true;
      };
      user.default = "flur";
      keyboard.layout = "us";
    };
  };

  # Follows the active theme-switch theme; falls back to rose-pine-moon
  systemd.services.noctalia-greeter-appearance = {
    description = "Sync noctalia-greeter appearance with active theme";
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ appearanceManifests ];
    serviceConfig.Type = "oneshot";
    script = ''
      theme=$(basename "$(readlink /home/flur/.config/themes/current)" 2>/dev/null) || true
      src="${appearanceManifests}/$theme.json"
      [ -e "$src" ] || src="${appearanceManifests}/rose-pine-moon.json"
      install -D -o greeter -g greeter -m 0644 "$src" /var/lib/noctalia-greeter/appearance.json
    '';
  };

  systemd.paths.noctalia-greeter-appearance = {
    wantedBy = [ "multi-user.target" ];
    pathConfig.PathChanged = "/home/flur/.config/themes/current";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    configPackages = [ pkgs.hyprland ];
    xdgOpenUsePortal = true;
  };

  # Desktop packages
  environment.systemPackages = with pkgs; [
    mako
    rose-pine-gtk-theme
    rose-pine-icon-theme
  ];
}
