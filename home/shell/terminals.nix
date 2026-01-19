{ pkgs, ... }:
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
