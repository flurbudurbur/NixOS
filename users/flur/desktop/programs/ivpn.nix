{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ivpn
    ivpn-ui
  ];
}
