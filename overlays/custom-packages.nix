# Overlay that adds custom packages to the pkgs namespace
final: prev: {
  bricolage-grotesque = final.callPackage ../packages/bricolage-grotesque.nix { };
  qobuz-player = final.callPackage ../packages/qobuz-player.nix { };
}
