{
  pkgs,
  config,
  lib,
  ...
}:

let
  signingKeyFile = "${config.xdg.configHome}/sops-secrets/git-signing-key";

  signingKey =
    if builtins.pathExists signingKeyFile then
      lib.removeSuffix "\n" (lib.fileContents signingKeyFile)
    else
      "59327CBED7938BDBE74B167D57CF006A8AD85F44";
in
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [
      "AGENTS.md"
      ".claude/*"
      "CLAUDE.md"
    ];
    settings = {
      user.name = "flurbudurbur";
      user.email = "69259138+flurbudurbur@users.noreply.github.com";
      user.signingkey = signingKey;
      init.defaultBranch = "main";
      pull.rebase = true;

      # GPG signing configuration
      commit.gpgsign = true;
      gpg.program = "${pkgs.gnupg}/bin/gpg";
    };
  };
}
