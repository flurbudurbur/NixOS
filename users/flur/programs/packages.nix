{ pkgs, oxicord, ... }:
{
  programs.foot.enable = true;

  home.packages = with pkgs; [
    oxicord.packages.x86_64-linux.default
    lazygit
    gnupg
    claude-code
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
    proton-pass
    kew
    prismlauncher

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

  services.gnome-keyring = {
    enable = true;
    components = [
      "pkcs11"
      "secrets"
      "ssh"
    ];
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "${../../../wallpaper.jpg}" ];
      wallpaper = [ ",${../../../wallpaper.jpg}" ];
    };
  };
}
