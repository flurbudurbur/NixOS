_: {
  users.groups.forgejo-backup = { };
  users.users.forgejo-backup = {
    isSystemUser = true;
    group = "forgejo-backup";
    home = "/srv/forgejo-backups";
    createHome = false;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHVMuhb+wnWBHFRIdsZo1XgopQjoR8QdJjwr9AzQlhWv forgejo-dump@flurLab"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/forgejo-backups 0755 root root - -"
    "d /srv/forgejo-backups/current 0750 forgejo-backup forgejo-backup - -"
  ];

  services.openssh.settings.AllowUsers = [
    "flur"
    "forgejo-backup@10.100.0.0/24"
  ];

  services.openssh.extraConfig = ''
    Match User forgejo-backup
      ChrootDirectory /srv/forgejo-backups
      ForceCommand internal-sftp
      AllowTcpForwarding no
      X11Forwarding no
      PermitTTY no
  '';
}
