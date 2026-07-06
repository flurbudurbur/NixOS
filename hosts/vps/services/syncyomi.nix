# SyncYomi (Tachiyomi sync server), migrated from ~/.config/syncyomi on the netcup box.
{
  config,
  lib,
  pkgs,
  secretsPath,
  ...
}:
let
  # Same fallback pattern as users/flur/programs/git.nix: build succeeds before the
  # secret exists in nix-secrets. Until then, a random secret is generated once and
  # persisted in StateDirectory instead of the old session's value (never want a
  # live credential landing in the world-readable Nix store).
  syncyomiSecretsFile = "${secretsPath}/system/vps/syncyomi.yaml";
  haveSyncyomiSecrets = builtins.pathExists syncyomiSecretsFile;
in
{
  users.users.syncyomi = {
    isSystemUser = true;
    group = "syncyomi";
  };
  users.groups.syncyomi = { };

  sops.secrets."syncyomi-session-secret" = lib.mkIf haveSyncyomiSecrets {
    sopsFile = syncyomiSecretsFile;
    owner = "syncyomi";
  };

  # Static parts only - sessionSecret is substituted in at service start.
  environment.etc."syncyomi/config.toml.template".text = ''
    host = "127.0.0.1"
    port = 8282
    logLevel = "DEBUG"
    checkForUpdates = true
    sessionSecret = "@SESSION_SECRET@"
  '';

  systemd.services.syncyomi = {
    description = "SyncYomi sync server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStartPre = pkgs.writeShellScript "syncyomi-render-config" (
        if haveSyncyomiSecrets then
          ''
            set -euo pipefail
            secret=$(cat ${config.sops.secrets."syncyomi-session-secret".path})
            sed "s|@SESSION_SECRET@|$secret|g" /etc/syncyomi/config.toml.template > /var/lib/syncyomi/config.toml
            chmod 600 /var/lib/syncyomi/config.toml
          ''
        else
          ''
            set -euo pipefail
            secret_file=/var/lib/syncyomi/.session-secret
            if [ ! -f "$secret_file" ]; then
              ${pkgs.openssl}/bin/openssl rand -hex 16 > "$secret_file"
              chmod 600 "$secret_file"
            fi
            secret=$(cat "$secret_file")
            sed "s|@SESSION_SECRET@|$secret|g" /etc/syncyomi/config.toml.template > /var/lib/syncyomi/config.toml
            chmod 600 /var/lib/syncyomi/config.toml
          ''
      );
      ExecStart = "${pkgs.syncyomi}/bin/syncyomi --config /var/lib/syncyomi";
      WorkingDirectory = "/var/lib/syncyomi";
      StateDirectory = "syncyomi";
      User = "syncyomi";
      Group = "syncyomi";
      Restart = "always";
    };
  };
}
