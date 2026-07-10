{ config, ... }:

{
  sops.templates."ssh-shiori-config".content = ''
    Host shiori
      HostName ${config.sops.placeholder."ssh-shiori-hostname"}
      User flur
      IdentityFile ~/.ssh/shiori

    Host music
      HostName ${config.sops.placeholder."ssh-shiori-hostname"}
      User music
      IdentityFile ~/.ssh/music
  '';

  programs.ssh.includes = [ config.sops.templates."ssh-shiori-config".path ];
}
