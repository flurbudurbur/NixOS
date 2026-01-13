{ ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$directory$git_branch$git_status$character";
      character = {
        success_symbol = "[➜](foam)";
        error_symbol = "[➜](love)";
      };
      directory.style = "bold iris";
      git_branch.style = "bold rose";
      git_status.style = "bold gold";
    };
  };
}
