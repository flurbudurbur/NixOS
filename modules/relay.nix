# Public relay for the homelab: WireGuard hub, spokes dial in, hub forwards
# spoke<->spoke traffic (no NAT to the internet - not an exit node).
{
  config,
  lib,
  secretsPath,
  ...
}:
let
  # The yaml needs a top-level `relay-wg-key:` whose value is the hub's
  # WireGuard private key. Falls back to a manually-placed key until then.
  wgSecretsFile = "${secretsPath}/system/relay/wireguard.yaml";
  haveWgSecrets = builtins.pathExists wgSecretsFile;
in
{
  sops.secrets."relay-wg-key" = lib.mkIf haveWgSecrets {
    sopsFile = wgSecretsFile;
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.firewall.trustedInterfaces = [ "wg0" ];

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile =
      if haveWgSecrets then config.sops.secrets."relay-wg-key".path else "/etc/wireguard/wg0.key";
    peers = [
      {
        publicKey = "FnG3IbiXK+aqC3WoGVzTGtz1oonnhDbOZ3ClYikdbXA=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
      {
        publicKey = "7oPIUBw0/kQL9xTmSBIcjPvGIeiSt+cG/ZMfZLFoI3c=";
        allowedIPs = [ "10.100.0.3/32" ];
      }
      {
        publicKey = "tjBxb72MHBbSEqFAQtDZ/Y2/BMt9uM/gJ0RUOGWioXw=";
        allowedIPs = [ "10.100.0.4/32" ];
      }
    ];
  };
}
