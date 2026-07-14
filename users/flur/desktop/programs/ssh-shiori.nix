{ config, ... }:

{
  sops.templates."ssh-shiori-config".content = ''
    Host shiori
      HostName ${config.sops.placeholder."ssh-shiori-hostname"}
      User flur
      IdentitiesOnly yes
      IdentityFile ~/.ssh/shiori

    Host music
      HostName ${config.sops.placeholder."ssh-flurlab-ip"}
      Port 2222
      User music
      IdentitiesOnly yes
      IdentityFile ~/.ssh/music
  '';

  programs.ssh.includes = [ config.sops.templates."ssh-shiori-config".path ];
}
