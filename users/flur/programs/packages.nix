{
  pkgs,
  nixpkgs-unstable,
  oxicord,
  wallpaperPath,
  ...
}:
{
  programs.foot.enable = true;

  home.packages = with pkgs; [
    oxicord.packages.x86_64-linux.default
    lazygit
    gnupg
    nixpkgs-unstable.claude-code
    vlc
    hyprpaper
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
    opentrack
    obs-studio

    # System utils
    grimblast
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

    # No Protondrive? No Problem!
    celeste
    rclone

    # Gaming
    lutris
    protonup-ng
    heroic

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

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "${wallpaperPath}" ];
      wallpaper = [ ",${wallpaperPath}" ];
    };
  };
}
