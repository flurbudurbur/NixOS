# Navidrome music server. Data lives on the 1TB HDD (hosts/flurLab/disko.nix
# mounts it at /data), same disk Forgejo already uses. Only reachable over the
# WireGuard relay tunnel (10.100.0.2) - the VPS Caddy proxies music.flur.dev to
# it for HTTPS (hosts/vps/services/caddy.nix).
#
# /data/music doubles as both Navidrome's MusicFolder and the SFTP upload
# target for the "music" user below (migrated here from the vps, which used
# to hold it at /srv/music). Ownership is music:music, mode 2750: the music
# user gets full read-write to upload/organize, and navidrome (added to the
# music group) gets read+traverse only - it only ever needs to read the
# library. Forgejo's built-in SSH server already takes the conventional :22
# for git clone URLs (see hosts/flurLab/default.nix), so the music user - like
# the rest of the host - is reached via the OpenSSH on :2222.
{ pkgs, ... }:
{
  services.navidrome = {
    enable = true;
    settings = {
      Address = "10.100.0.2";
      Port = 4533;
      MusicFolder = "/data/music";
      DataFolder = "/data/navidrome";
    };
  };

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 4533 ];

  users.groups.music = { };
  users.users.navidrome.extraGroups = [ "music" ];

  # Unconditional (no ":" prefix), so it always wins over the upstream
  # Navidrome module's own create-once MusicFolder tmpfiles rule.
  systemd.tmpfiles.rules = [ "d /data/music 2750 music music - -" ];

  # SFTP/shell upload account - no service runs as this user.
  users.users.music = {
    isNormalUser = true;
    home = "/data/music";
    group = "music";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnpkT52t3MkXqJUEWAeWRyHXlTNrgIpGy+A12wkJm5s music@v2202512321715414857"
    ];
  };
}
