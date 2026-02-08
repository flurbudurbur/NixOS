{ pkgs, config, lib, ... }:
let
  themesPath = "${config.xdg.configHome}/heroic/themes";

  # Fetch rose-pine.css from GitHub
  rosePineTheme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/Heroic-Games-Launcher/heroic-themes/refs/heads/main/Ros%C3%A9%20Pine/rose-pine.css";
    sha256 = "sha256-soo0AoYrQplbuLt/tQqavLZwu6+eDUEIC6wwANYF/jY=";
  };

  # Create a Nix script that uses builtins to update the JSON
  updateConfigScript = pkgs.writeText "update-heroic-config.nix" ''
    let
      configPath = builtins.getEnv "HEROIC_CONFIG_FILE";
      themesPath = builtins.getEnv "THEMES_PATH";

      existingConfig = builtins.fromJSON (builtins.readFile configPath);

      updatedConfig = existingConfig // {
        defaultSettings = existingConfig.defaultSettings // {
          customThemesPath = themesPath;
        };
      };
    in
      builtins.toJSON updatedConfig
  '';
in
{
  # Heroic Games Launcher with Rose Pine Moon theme
  # Creates custom themes directory and copies theme files automatically

  # Copy theme files to Heroic themes directory
  xdg.configFile."heroic/themes/rose-pine.css".source = rosePineTheme;

  # Update Heroic config with customThemesPath using Nix builtins
  home.activation.setupHeroicThemes = lib.hm.dag.entryAfter ["writeBoundary"] ''
    HEROIC_CONFIG_FILE="${config.xdg.configHome}/heroic/config.json"
    THEMES_PATH="${themesPath}"

    if [ -f "$HEROIC_CONFIG_FILE" ]; then
      # Use nix-instantiate to evaluate the Nix expression that updates the JSON
      export HEROIC_CONFIG_FILE THEMES_PATH
      UPDATED_JSON=$(${pkgs.nix}/bin/nix-instantiate --eval --strict --json ${updateConfigScript} | ${pkgs.jq}/bin/jq -r)

      # Write the updated config
      echo "$UPDATED_JSON" > "$HEROIC_CONFIG_FILE"
    fi
  '';
}
