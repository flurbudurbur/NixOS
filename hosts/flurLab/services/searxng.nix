# SearXNG + Valkey. Reachable over the WireGuard tunnel (10.100.0.2);
# vps Caddy proxies srx.flur.dev to it. Egress routes through vps's
# egress-proxy so queries exit from the vps's IP instead of home.
{
  config,
  pkgs,
  secretsPath,
  ...
}:
{
  virtualisation.oci-containers.backend = "podman";

  # podman module only opens udp/53 for aardvark-dns on podman0, not this bridge - else DNS silently fails
  networking.firewall.interfaces."podman1".allowedUDPPorts = [ 53 ];

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 8080 ];

  users.users.searxng = {
    isSystemUser = true;
    group = "searxng";
    uid = 977;
  };
  users.groups.searxng.gid = 977;

  sops.secrets."searxng-secret-key".sopsFile = "${secretsPath}/system/flurLab/searxng.yaml";

  # secret_key can't be a plain Nix string (would land world-readable in /nix/store)
  sops.templates."searxng-settings.yml" = {
    owner = "searxng";
    # settings.yml is only read at startup - restart on template change
    restartUnits = [ "podman-searxng.service" ];
    content = ''
      use_default_settings: true
      search:
        formats:
          - html
          - json
      server:
        secret_key: "${config.sops.placeholder."searxng-secret-key"}"
        image_proxy: true
      outgoing:
        proxies:
          all://: "socks5h://10.100.0.1:1080"
    '';
  };

  systemd.services.podman-network-searxng = {
    description = "Ensure the podman network for SearXNG exists";
    after = [ "network.target" ];
    before = [
      "podman-searxng.service"
      "podman-searxng-valkey.service"
    ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman network exists searxng || podman network create searxng
    '';
  };

  virtualisation.oci-containers.containers = {
    searxng-valkey = {
      image = "docker.io/valkey/valkey:8-alpine";
      cmd = [
        "valkey-server"
        "--save"
        "30"
        "1"
        "--loglevel"
        "warning"
      ];
      volumes = [ "searxng-valkey:/data" ];
      extraOptions = [
        "--network=searxng"
        "--network-alias=searxng-valkey"
        "--cap-drop=all"
        "--cap-add=SETGID"
        "--cap-add=SETUID"
        "--cap-add=DAC_OVERRIDE"
      ];
    };

    searxng = {
      image = "docker.io/searxng/searxng:latest";
      ports = [ "10.100.0.2:8080:8080" ];
      volumes = [ "${config.sops.templates."searxng-settings.yml".path}:/etc/searxng/settings.yml:ro" ];
      environment.SEARXNG_BASE_URL = "https://srx.flur.dev/";
      dependsOn = [ "searxng-valkey" ];
      extraOptions = [
        "--network=searxng"
        "--network-alias=searxng"
        "--user=977:977"
        "--cap-drop=all"
      ];
    };
  };

  systemd.services.podman-searxng.after = [ "podman-network-searxng.service" ];
  systemd.services.podman-searxng.requires = [ "podman-network-searxng.service" ];
  systemd.services.podman-searxng-valkey.after = [ "podman-network-searxng.service" ];
  systemd.services.podman-searxng-valkey.requires = [ "podman-network-searxng.service" ];
}
