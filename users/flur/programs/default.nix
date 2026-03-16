{ ... }:
{
  imports = [
    ./git.nix
    ./ssh.nix
    ./packages.nix
    ./dev.nix
    ./xdg.nix
    ./nvim.nix
    ./nixcord.nix
    ./zen-browser.nix
    ./gpg.nix
    ./persepolis.nix
    ./flatpak.nix
    ./mullvad-vpn.nix
    ./heroic.nix
    ./composer.nix
    ./rust.nix
    ./android.nix
  ];
}
