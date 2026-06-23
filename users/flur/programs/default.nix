{ ... }:
{
  imports = [
    ./git.nix
    ./ssh.nix
    ./packages.nix
    ./dev.nix
    ./xdg.nix
    ./nvim.nix
    ./zen-browser.nix
    ./gpg.nix
    ./persepolis.nix
    ./flatpak.nix
    ./mullvad-vpn.nix
    ./heroic.nix
  ];
}
