{ pkgs, ... }:
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        shell = "${pkgs.zsh}/bin/zsh";
        font = "MapleMono NF:size=12";
        pad = "10x10";
        include = "/home/flur/.config/themes/current/foot-colors.ini";
      };
    };
  };
}
