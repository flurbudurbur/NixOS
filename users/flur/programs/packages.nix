{
  lib,
  pkgs,
  nixpkgs-unstable,
  ...
}:
{
  programs =
    lib.genAttrs
      [
        "foot"
        "lazygit"
        "prismlauncher"
        "obs-studio"
        "hyprshot"
        "rclone"
        "lutris"
      ]
      (_: {
        enable = true;
      })
    // {
      btop.settings = {
        theme_background = false;
        vim_keys = true;
        rounded_corners = false;
      };
    };

  home.packages = with pkgs; [
    gnupg
    nixpkgs-unstable.claude-code
    vlc
    teams-for-linux
    pwvucontrol
    nautilus
    file-roller
    unzip
    zip
    p7zip
    unrar
    flatpak
    popcorntime
    qbittorrent
    proton-pass
    kew
    openrgb-with-all-plugins

    # Clipboard
    cliphist
    wl-clipboard

    # System utils
    libnotify
    grimblast
    bluetui
    bandwhich
    nethogs
    iftop

    # Productivity
    libreoffice-fresh
    krita

    # No Protondrive? No Problem!
    celeste

    # Gaming
    protonup-ng
    nixpkgs-unstable.heroic

    # Music
    qobuz-player

    # Chat
    fluxer-tui
  ];

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };
}
