# Overlay that adds custom packages to the pkgs namespace
{ inputs }:
final: _prev:
let
  themes = import ../modules/themes/default.nix { schemes = inputs.tinted-schemes; };
  mkPlymouthTheme = final.callPackage ../packages/plymouth-theme.nix { };

  wallpaperExts = [
    "jpg"
    "png"
    "webp"
    "gif"
  ];
  wallpaperFor =
    name:
    final.lib.findFirst (
      ext: builtins.pathExists (../wallpapers + "/${name}.${ext}")
    ) null wallpaperExts;
in
{
  autour-one = final.callPackage ../packages/autour-one.nix { };
  bricolage-grotesque = final.callPackage ../packages/bricolage-grotesque.nix { };
  fluxer-tui = final.callPackage ../packages/fluxer-tui.nix { };
  nova-mono = final.callPackage ../packages/nova-mono.nix { };
  qobuz-player = final.callPackage ../packages/qobuz-player.nix { };

  # One Plymouth boot-splash theme per color theme in modules/themes/,
  # keyed by theme name (e.g. plymouthThemes.rose-pine-moon). Uses the
  # matching wallpaper from wallpapers/ as the boot background when present.
  plymouthThemes = builtins.mapAttrs (
    name: t:
    let
      ext = wallpaperFor name;
    in
    mkPlymouthTheme {
      inherit name;
      inherit (t) bg;
      dot = t.blue;
      wallpaper = if ext != null then (../wallpapers + "/${name}.${ext}") else null;
    }
  ) themes;
}
