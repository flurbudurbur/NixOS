{ config, ... }:

{
  sops.templates."git-signing-key-config".content = ''
    [user]
      signingkey = ${config.sops.placeholder."git-signing-key"}
  '';

  programs.git.includes = [ { path = config.sops.templates."git-signing-key-config".path; } ];
}
