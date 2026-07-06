# flur34.com / beta.flur34.com - KuroSearch (ghcr.io/flur34/flur34), migrated from
# ~/flur34_stuff/{flur34,flur34b}/compose.yaml on the netcup box. Caddy (modules/caddy.nix)
# reverse-proxies to these on localhost; the Caddyfiles bundled in flur34_stuff are just
# the upstream project's own example and aren't used here.
{
  config,
  lib,
  pkgs,
  secretsPath,
  ...
}:
let
  flur34SecretsFile = "${secretsPath}/system/vps/flur34.yaml";
  flur34BetaSecretsFile = "${secretsPath}/system/vps/flur34-beta.yaml";
  haveFlur34Secrets = builtins.pathExists flur34SecretsFile;
  haveFlur34BetaSecrets = builtins.pathExists flur34BetaSecretsFile;

  # Seeds an editable placeholder env file the first time; never overwrites it afterwards.
  # Real values (RULE34_API_KEY/USER, FRONTEND_ORIGIN, ...) belong in nix-secrets, not here.
  flur34EnvPlaceholder = pkgs.writeText "flur34.env.placeholder" ''
    RULE34_API_KEY=
    RULE34_API_USER=
    FRONTEND_ORIGIN=
  '';
  flur34BetaEnvPlaceholder = pkgs.writeText "flur34-beta.env.placeholder" ''
    RULE34_API_KEY=
    RULE34_API_USER=
    FRONTEND_ORIGIN=
    WATCHTOWER_HTTP_API_UPDATE=
    WATCHTOWER_HTTP_API_TOKEN=
    WATCHTOWER_CLEANUP=
    WATCHTOWER_INCLUDE_STOPPED=
    WATCHTOWER_LABEL_ENABLE=
    KUROSEARCH_CANONICAL_URL=
  '';
in
{
  sops.secrets."flur34-env" = lib.mkIf haveFlur34Secrets { sopsFile = flur34SecretsFile; };
  sops.secrets."flur34-beta-env" = lib.mkIf haveFlur34BetaSecrets {
    sopsFile = flur34BetaSecretsFile;
  };

  systemd.tmpfiles.rules = [
    "C /etc/flur34/flur34.env 0600 root root - ${flur34EnvPlaceholder}"
    "C /etc/flur34/flur34-beta.env 0600 root root - ${flur34BetaEnvPlaceholder}"
  ];

  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers = {
    flur34 = {
      image = "ghcr.io/flur34/flur34:latest";
      ports = [ "127.0.0.1:8181:8080" ];
      environmentFiles = [
        (if haveFlur34Secrets then config.sops.secrets."flur34-env".path else "/etc/flur34/flur34.env")
      ];
      log-driver = "json-file";
      extraOptions = [
        "--log-opt=max-size=1m"
        "--log-opt=max-file=1"
      ];
    };

    flur34-beta = {
      image = "ghcr.io/flur34/flur34:canary";
      ports = [ "127.0.0.1:8383:8080" ];
      environmentFiles = [
        (
          if haveFlur34BetaSecrets then
            config.sops.secrets."flur34-beta-env".path
          else
            "/etc/flur34/flur34-beta.env"
        )
      ];
      labels."com.centurylinklabs.watchtower.enable" = "true";
      log-driver = "json-file";
      extraOptions = [
        "--log-opt=max-size=1m"
        "--log-opt=max-file=1"
      ];
    };
  };
}
