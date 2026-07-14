# SOCKS5 egress for SearXNG on flurLab, wg0-only (not a general exit node).
{ pkgs, ... }:
{
  networking.firewall.interfaces."wg0".allowedTCPPorts = [ 1080 ];

  systemd.services.egress-proxy = {
    description = "MicroSocks SOCKS5 egress proxy (wg0-only)";
    after = [ "wireguard-wg0.service" ];
    requires = [ "wireguard-wg0.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.microsocks}/bin/microsocks -i 10.100.0.1 -p 1080";
      DynamicUser = true;
      Restart = "always";
    };
  };
}
