{ pkgs, ... }:
let
  c = import ../../modules/colors.nix;
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell = "${pkgs.zsh}/bin/zsh";
      window = {
        padding = {
          x = 10;
          y = 10;
        };
      };
    };
  };
}
