{ pkgs, lib, ... }:
{
  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # User accounts
  users.users.flur = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" ];
    shell = pkgs.zsh;
  };
  environment.shells = with pkgs; [ zsh ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    (pkgs.callPackage ./custom/fonts/bricolage.nix {})
  ];

  # Services
  services = {
    pulseaudio.enable = false;
    flatpak.enable = true;
    keyd = {
      enable = true;
      keyboards.default = {
        ids = ["*"];
        settings.main = {
          capslock = "layer(control)";
          control = "capslock";
        };
      };
    };
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    gnome.gnome-online-accounts.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  # Security
  security.rtkit.enable = true;
  security.pam.services.hyprlock = {};

  # Locale
  time.timeZone = "Europe/Amsterdam";

  # System packages (basic tools)
  environment.systemPackages = with pkgs; [
    git
    pciutils
    tree
    wget
    btop
    bat
  ];

  programs.zsh.enable = true;
  programs.steam.enable = true;
}
