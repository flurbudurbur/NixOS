{ pkgs, ... }:
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        shell = "${pkgs.zsh}/bin/zsh";
        pad = "10x10";
      };
    };
  };
}
