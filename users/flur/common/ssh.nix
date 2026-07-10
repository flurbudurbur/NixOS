_:

{
  # Force overwrite to prevent backup file conflicts
  home.file.".ssh/config".force = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };

      "github.com" = {
        IdentitiesOnly = true;
        IdentityFile = [
          "~/.ssh/id_ed25519_sk_rk_aloha"
          "~/.ssh/id_ed25519_sk_rk_pink"
          "~/.ssh/github"
        ];
      };

      "codeberg.org" = {
        IdentitiesOnly = true;
        IdentityFile = [
          "~/.ssh/id_ed25519_sk_rk_aloha_codeberg"
          "~/.ssh/id_ed25519_sk_rk_pink_codeberg"
          "~/.ssh/codeberg"
        ];
      };
    };
  };
}
