{ ... }:
let
  c = import ../../modules/colors.nix;
in
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      palette = "rose-pine-moon";
      palettes.rose-pine-moon = {
        base = c.base;
        surface = c.surface;
        overlay = c.overlay;
        muted = c.muted;
        subtle = c.subtle;
        text = c.text;
        love = c.love;
        gold = c.gold;
        rose = c.rose;
        pine = c.pine;
        foam = c.foam;
        iris = c.iris;
      };
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
