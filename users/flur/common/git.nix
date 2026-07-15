{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;

    # Codeberg/Forgejo can only verify signatures against emails on file for
    # the account, so override the committer email for their remotes
    includes =
      let
        codebergEmail = {
          contents.user.email = "flurbudurbur@noreply.codeberg.org";
        };
        forgejoEmail = {
          contents.user.email = "flur@noreply.flur.dev";
        };
      in
      [
        (codebergEmail // { condition = "hasconfig:remote.*.url:git@codeberg.org:*/**"; })
        (codebergEmail // { condition = "hasconfig:remote.*.url:ssh://git@codeberg.org/**"; })
        (codebergEmail // { condition = "hasconfig:remote.*.url:https://codeberg.org/**"; })
        (forgejoEmail // { condition = "hasconfig:remote.*.url:git@git.flur.dev:*/**"; })
        (forgejoEmail // { condition = "hasconfig:remote.*.url:ssh://git@git.flur.dev/**"; })
        (forgejoEmail // { condition = "hasconfig:remote.*.url:https://git.flur.dev/**"; })
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
      # Real key comes from ../../desktop/programs/git-signing-key.nix via a
      # sops-rendered include (desktop only - vps has no sops-nix HM module).
      # This is the pre-age-migration key ID, kept as a bootstrap fallback.
      user.signingkey = "59327CBED7938BDBE74B167D57CF006A8AD85F44";
      init.defaultBranch = "main";
      pull.rebase = true;

      # GPG signing configuration
      commit.gpgsign = true;
      gpg.program = "${pkgs.gnupg}/bin/gpg";
    };
  };
}
