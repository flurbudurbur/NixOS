{ ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    # Read TOML file directly to preserve all Unicode characters
    settings = builtins.fromTOML (builtins.readFile ./starship.toml);
  };
}
