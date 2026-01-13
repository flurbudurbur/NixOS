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
    xplr
    pwvucontrol
    nautilus
    file-roller
    unzip
    zip
    p7zip
    unrar
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
      preload = [ "~/.config/wallpapers/wallpaper.jpg" ];
      wallpaper = [ ",~/.config/wallpapers/wallpaper.jpg" ];
    };
  };

  services.flatpak = {
    enable = true;
    update.onActivation = true;
    remotes = [{
      name = "flathub";
      location = "https://flathub.org/repo/flathub.flatpakrepo";
    }];
    packages = [ "com.usebottles.bottles" ];
    overrides = {
      "com.usebottles.bottles" = {
        Context.filesystems = [
          "xdg-config/gtk-3.0:ro"
          "xdg-run/dconf"
        ];
        Environment.GTK_USE_PORTAL = "1";
      };
    };
  };
}
