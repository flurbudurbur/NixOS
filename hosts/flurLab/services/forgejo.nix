# Private git server. HTTP fronted by vps Caddy (git.flur.dev); SSH rides the
# host's own OpenSSH (server.nix) rather than Forgejo's built-in SSH server -
# see git history for why (the built-in server's internal auth callback
# silently rejected valid, DB-verified keys; `forgejo serv key-N` against the
# same DB succeeded fine). Forgejo runs as the conventional "git" system user
# so it can write ~git/.ssh/authorized_keys directly (SSH_CREATE_AUTHORIZED_KEYS_FILE,
# default true) - the only well-supported classic integration; `forgejo serv`
# only accepts a numeric key ID, not the fingerprint sshd's AuthorizedKeysCommand
# %f token provides, so that route (tried first) doesn't work with this version.
{ config, pkgs, ... }:
let
  cfg = config.services.forgejo;
in
{
  # forgejo CLI on PATH for admin commands (forgejo admin user create, etc.)
  environment.systemPackages = [ pkgs.forgejo ];

  services.forgejo = {
    enable = true;
    stateDir = "/data/forgejo";
    lfs.enable = true;
    user = "git";
    group = "git";

    settings = {
      DEFAULT.APP_NAME = "Flurgejo";

      server = {
        DOMAIN = "git.flur.dev";
        ROOT_URL = "https://git.flur.dev/";
        HTTP_ADDR = "10.100.0.2";
        HTTP_PORT = 3000;

        START_SSH_SERVER = false;
        SSH_DOMAIN = "git.flur.dev";
        SSH_USER = "git";
        SSH_PORT = 22;

        OFFLINE_MODE = true;
      };
      service = {
        DISABLE_REGISTRATION = true;
        NO_REPLY_ADDRESS = "noreply.flur.dev";
        REQUIRE_SIGNIN_VIEW = true;
      };
      picture.DISABLE_GRAVATAR = true;
      other.SHOW_FOOTER_VERSION = false;
    };
  };

  # The module only auto-creates a "forgejo" user/group at its default
  # user/group names; since we point it at "git" instead, mirror that same
  # definition (home = stateDir, so ~git/.ssh/authorized_keys lands in
  # /data/forgejo/.ssh, which Forgejo already owns and writes to).
  users.users.git = {
    home = cfg.stateDir;
    useDefaultShell = true;
    group = "git";
    isSystemUser = true;
  };
  users.groups.git = { };

  systemd.tmpfiles.rules = [
    "d /data/forgejo-backups 0750 git git - -"
    "d /var/lib/forgejo-backup-key 0700 git git - -"
  ];

  systemd.services.forgejo-dump = {
    description = "Forgejo data dump";
    after = [ "forgejo.service" ];
    path = [
      pkgs.forgejo
      pkgs.openssh
    ];
    environment = {
      GITEA_WORK_DIR = "/data/forgejo";
      GITEA_CUSTOM = "/data/forgejo/custom";
    };
    serviceConfig = {
      Type = "oneshot";
      User = "git";
      Group = "git";
      WorkingDirectory = "/data/forgejo-backups";
    };
    script = ''
      dump="forgejo-dump-$(date +%Y%m%d-%H%M%S).zip"
      forgejo dump --type zip --file "$dump"
      find /data/forgejo-backups -name 'forgejo-dump-*.zip' -mtime +14 -delete

      key=/var/lib/forgejo-backup-key/id_ed25519
      known=/var/lib/forgejo-backup-key/known_hosts
      target=forgejo-backup@10.100.0.1
      sftp_opts=(-i "$key" -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile="$known")

      if [ ! -f "$key" ]; then
        echo "forgejo-backup-key missing at $key, skipping off-site push" >&2
        exit 0
      fi

      remote_list=$(printf 'cd current\n-ls -1 forgejo-dump-*.zip\n' \
        | sftp "''${sftp_opts[@]}" -b - "$target" 2>/dev/null) || true
      local_list=$(ls forgejo-dump-*.zip)

      batch=$(mktemp)
      {
        echo "cd current"
        echo "put $dump"
        for f in $remote_list; do
          case "$f" in
            forgejo-dump-*.zip)
              printf '%s\n' "$local_list" | grep -qxF "$f" || echo "rm $f"
              ;;
          esac
        done
      } > "$batch"

      sftp "''${sftp_opts[@]}" -b "$batch" "$target"
      rm -f "$batch"
    '';
  };

  systemd.timers.forgejo-dump = {
    description = "Daily Forgejo data dump";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };

  # wg0-only, matching wireguard.nix's "no inbound at home" setup. SSH clone
  # traffic now rides the host's own sshd (server.nix, port 22) via the
  # git user's own authorized_keys, no separate port needed here.
  networking.firewall.interfaces.wg0.allowedTCPPorts = [
    3000
  ];
}
