# Forgejo (community-governed Gitea fork), private git server for personal
# repos. Data lives on the 1TB HDD (hosts/flurLab/disko.nix mounts it at
# /data). Only reachable over the WireGuard relay tunnel (10.100.0.2) - the
# VPS Caddy proxies git.flur.dev to it for HTTPS (hosts/vps/services/caddy.nix);
# SSH clone stays tunnel-only since Caddy can't forward raw TCP without an
# extra L4 plugin.
#
# Forgejo's built-in SSH server takes the conventional :22 for clone URLs, so
# the host's own OpenSSH is moved to :2222 (see hosts/flurLab/default.nix).
{ pkgs, ... }:
{
  # The module wires the binary onto the service's own PATH but not the
  # system's. Needed for admin commands, e.g.:
  #   sudo -u forgejo env GITEA_WORK_DIR=/data/forgejo GITEA_CUSTOM=/data/forgejo/custom \
  #     forgejo admin user create --admin --username <you> --password <pw> --email <email>
  environment.systemPackages = [ pkgs.forgejo ];

  services.forgejo = {
    enable = true;
    stateDir = "/data/forgejo";

    settings = {
      DEFAULT.APP_NAME = "Flurgejo";

      server = {
        DOMAIN = "git.flur.dev";
        ROOT_URL = "https://git.flur.dev/";
        HTTP_ADDR = "10.100.0.2";
        HTTP_PORT = 3000;

        SSH_DOMAIN = "flurLab";
        SSH_LISTEN_HOST = "10.100.0.2";
        SSH_LISTEN_PORT = 22;
        SSH_PORT = 22;
      };
      service.DISABLE_REGISTRATION = true;
    };
  };

  # Firewall already scoped by HTTP_ADDR/SSH_LISTEN_HOST above; this just
  # restricts at the interface level too, matching wireguard.nix's
  # "no inbound ports at home" intent.
  networking.firewall.interfaces.wg0.allowedTCPPorts = [
    3000
    22
  ];
}
