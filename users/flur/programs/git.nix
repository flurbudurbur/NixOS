{ pkgs, config, lib, ... }:

let
  signingKeyFile = "${config.xdg.configHome}/sops-secrets/git-signing-key";
  sshHostnameFile = "${config.xdg.configHome}/sops-secrets/ssh-shiori-hostname";

  signingKey = if builtins.pathExists signingKeyFile
    then lib.removeSuffix "\n" (lib.fileContents signingKeyFile)
    else "59327CBED7938BDBE74B167D57CF006A8AD85F44";

  sshHostname = if builtins.pathExists sshHostnameFile
    then lib.removeSuffix "\n" (lib.fileContents sshHostnameFile)
    else "console.flur.dev";
in
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "flurbudurbur";
      user.email = "69259138+flurbudurbur@users.noreply.github.com";
      user.signingkey = signingKey;
      init.defaultBranch = "main";

      # GPG signing configuration
      commit.gpgsign = true;
      gpg.program = "${pkgs.gnupg}/bin/gpg";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*".addKeysToAgent = "yes";
      "github.com".identityFile = "~/.ssh/github";
      "shiori" = {
        identityFile = "~/.ssh/shiori";
        user = "flur";
        hostname = sshHostname;
      };
    };
  };
}
