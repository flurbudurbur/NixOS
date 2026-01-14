{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "flurbudurbur";
      user.email = "69259138+flurbudurbur@users.noreply.github.com";
      user.signingkey = "59327CBED7938BDBE74B167D57CF006A8AD85F44";
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
        hostname = "console.flur.dev";
      };
    };
  };
}
