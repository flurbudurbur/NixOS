# Spoke: dials out to the relay hub (modules/relay.nix) - no inbound ports at home.
{
  config,
  lib,
  secretsPath,
  ...
}:
let
  # The yaml needs a top-level `flurlab-wg-key:` whose value is this host's
  # WireGuard private key. Falls back to a manually-placed key until then.
  wgSecretsFile = "${secretsPath}/system/flurLab/wireguard.yaml";
  haveWgSecrets = builtins.pathExists wgSecretsFile;
in
{
  sops.secrets."flurlab-wg-key" = lib.mkIf haveWgSecrets {
    sopsFile = wgSecretsFile;
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.2/32" ];
    privateKeyFile =
      if haveWgSecrets then config.sops.secrets."flurlab-wg-key".path else "/etc/wireguard/wg0.key";
    peers = [
      {
        publicKey = "hukhpVDFtHOFAj5o+KIKmXZaQkAfIRaOSMNuk6cROnY=";
        allowedIPs = [ "10.100.0.0/24" ];
        endpoint = "relay.flur.dev:51820";
        persistentKeepalive = 25;
      }
    ];
  };
}
