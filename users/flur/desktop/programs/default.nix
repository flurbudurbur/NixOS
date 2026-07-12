{ ... }:
{
  imports = [
    ../../common/git.nix
    ../../common/ssh.nix
    ./ssh-shiori.nix
    ./ssh-flurlab.nix
    ./git-signing-key.nix
    ./packages.nix
    ./dev.nix
    ./xdg.nix
    ./nvim.nix
    ./nix-index.nix
    ./zen-browser.nix
    ./gpg.nix
    ./persepolis.nix
    ./flatpak.nix
    ./ivpn.nix
    ./heroic.nix
  ];
}
