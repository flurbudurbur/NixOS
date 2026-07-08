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

    # Codeberg can only verify signatures against emails on the Codeberg
    # account, so override the committer email for codeberg.org remotes
    includes =
      let
        codebergEmail = {
          contents.user.email = "flurbudurbur@noreply.codeberg.org";
        };
      in
      [
        (codebergEmail // { condition = "hasconfig:remote.*.url:git@codeberg.org:*/**"; })
        (codebergEmail // { condition = "hasconfig:remote.*.url:https://codeberg.org/**"; })
      ];
    ignores = [
      "AGENTS.md"
      ".claude/*"
      "CLAUDE.md"
      ".direnv/*"
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
