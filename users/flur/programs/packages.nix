{
  pkgs,
  nixpkgs-unstable,
  ...
}:
{
  programs.foot.enable = true;

  home.packages = with pkgs; [
    lazygit
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
    prismlauncher
    obs-studio
    openrgb-with-all-plugins

    # Clipboard
    cliphist
    wl-clipboard

    # System utils
    grimblast
    hyprshot
    bluetui
    bandwhich
    nethogs
    iftop

    # Tmux utils
    sesh
    fzf
    fd
    zoxide
    ripgrep

    # Productivity
    libreoffice-fresh
    krita

    # No Protondrive? No Problem!
    celeste
    rclone

    # Gaming
    lutris
    protonup-ng
    nixpkgs-unstable.heroic

    # Music
    qobuz-player
  ];

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  programs.btop.settings = {
    theme_background = false;
    vim_keys = true;
    rounded_corners = false;
  };

}
