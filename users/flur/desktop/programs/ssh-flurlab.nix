{ config, ... }:

{
  sops.templates."ssh-flurlab-config".content = ''
    Host flurLab flurlab fl
      HostName ${config.sops.placeholder."ssh-flurlab-ip"}
      Port 22
      User flur
      IdentitiesOnly yes
      IdentityFile ~/.ssh/shiori

    Host git.flur.dev
      HostName ${config.sops.placeholder."ssh-flurlab-ip"}
      Port 22
      User git
      IdentitiesOnly yes
      IdentityFile ~/.ssh/id_ed25519_sk_rk_aloha_forgejo
      IdentityFile ~/.ssh/id_ed25519_sk_rk_pink_forgejo
      IdentityFile ~/.ssh/forgejo
  '';

  programs.ssh.includes = [ config.sops.templates."ssh-flurlab-config".path ];
}
