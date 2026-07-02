# Overlay that adds custom packages to the pkgs namespace
final: prev: {
  autour-one = final.callPackage ../packages/autour-one.nix { };
  bricolage-grotesque = final.callPackage ../packages/bricolage-grotesque.nix { };
  nova-mono = final.callPackage ../packages/nova-mono.nix { };
  qobuz-player = final.callPackage ../packages/qobuz-player.nix { };
  rose-pine-plymouth = final.callPackage ../packages/rose-pine-plymouth.nix { };
}
