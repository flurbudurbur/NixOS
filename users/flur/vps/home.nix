# Minimal home-manager profile for headless/server hosts.
#
# Deliberately not reusing users/flur/desktop/home.nix - that pulls in Hyprland,
# zen-browser, Heroic, IVPN and other desktop-only config. This profile only
# carries what's useful over SSH, sharing just the truly common bits from
# users/flur/common/.
{ lib, ... }:
{
  imports = [
    ../common/git.nix
    ../common/ssh.nix
  ];

  home = {
    username = "flur";
    homeDirectory = "/home/flur";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  # No Yubikey on the server to sign with
  programs.git.settings.commit.gpgsign = lib.mkForce false;

  programs.starship.enable = true;
  programs.starship.enableFishIntegration = true;

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = true;
    icons = "auto";
    colors = "always";
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };

  programs.fzf.enable = true;
  programs.fzf.enableFishIntegration = true;
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [
      "--cmd"
      "cd"
    ];
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "eza";
      nrt = "nixos-rebuild test --sudo --flake /home/flur/nixos-system-vps";
      nrs = "nixos-rebuild switch --sudo --flake /home/flur/nixos-system-vps";
      nfc = "nix flake check --no-build /home/flur/nixos-system-vps";
      nf = "nix fmt /home/flur/nixos-system-vps";
    };
    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };
}
