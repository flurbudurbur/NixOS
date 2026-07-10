# SearXNG + Valkey, migrated from the rootless podman quadlets that lived in
# ~/.config/containers/systemd/searxng on the netcup box. Runs system-wide via
# virtualisation.oci-containers here instead of per-user quadlets.
{ pkgs, ... }:
{
  virtualisation.oci-containers.backend = "podman";

  # NixOS's podman module only opens udp/53 to the default network's
  # interface (podman0) for aardvark-dns. The searxng network is a separate
  # user-defined bridge (podman1), so without this its containers can reach
  # the internet by IP but can never resolve hostnames - every search engine
  # request times out looking exactly like a network outage.
  networking.firewall.interfaces."podman1".allowedUDPPorts = [ 53 ];

  users.users.searxng = {
    isSystemUser = true;
    group = "searxng";
    uid = 977;
  };
  users.groups.searxng.gid = 977;

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
      ports = [ "127.0.0.1:8080:8080" ];
      volumes = [ "/var/lib/searxng:/etc/searxng" ];
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

  systemd.tmpfiles.rules = [
    "d /var/lib/searxng 0750 searxng searxng -"
  ];
}
