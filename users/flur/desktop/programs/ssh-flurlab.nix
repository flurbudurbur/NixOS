{ config, ... }:

{
  sops.templates."ssh-flurlab-config".content = ''
    Host flurLab flurlab fl
      HostName ${config.sops.placeholder."ssh-flurlab-ip"}
      User flur
      IdentitiesOnly yes
      IdentityFile ~/.ssh/shiori
  '';

  programs.ssh.includes = [ config.sops.templates."ssh-flurlab-config".path ];
}
