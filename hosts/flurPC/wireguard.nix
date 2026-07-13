# Spoke: dials out to the relay hub (modules/relay.nix) to reach flurLab remotely.
{
  config,
  lib,
  secretsPath,
  ...
}:
let
  # The yaml needs a top-level `flurpc-wg-key:` whose value is this host's
  # WireGuard private key. Falls back to a manually-placed key until then.
  wgSecretsFile = "${secretsPath}/system/flurPC/wireguard.yaml";
  haveWgSecrets = builtins.pathExists wgSecretsFile;
in
{
  sops.secrets."flurpc-wg-key" = lib.mkIf haveWgSecrets {
    sopsFile = wgSecretsFile;
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.3/32" ];
    privateKeyFile =
      if haveWgSecrets then config.sops.secrets."flurpc-wg-key".path else "/etc/wireguard/wg0.key";
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
