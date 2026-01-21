{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rose-pine-gtk-theme
    rose-pine-icon-theme
    lazygit
    gnupg
    vesktop
    claude-code
    hyprpaper
    teams-for-linux
    pwvucontrol
    nautilus
    file-roller
    unzip
    zip
    p7zip
    unrar
    nur.repos.foolnotion.qobuz-linux
    flatpak
    popcorntime
    proton-pass
    grimblast

    # Wine with 32/64-bit support and Wayland
    wineWowPackages.waylandFull
    winetricks
  ];

  programs.btop.settings = {
    theme_background = false;
    vim_keys = true;
    rounded_corners = false;
  };

  services.gnome-keyring = {
    enable = true;
    components = [ "pkcs11" "secrets" "ssh" ];
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "${../../wallpaper.jpg}" ];
      wallpaper = [ ",${../../wallpaper.jpg}" ];
    };
  };
}
