{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "flurbudurbur";
      user.email = "69259138+flurbudurbur@users.noreply.github.com";
      init.defaultBranch = "main";
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
