{ pkgs, ... }:
{
  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };

  environment.systemPackages = [ pkgs.opentabletdriver ];
}
