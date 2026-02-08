{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    php
    phpPackages.composer
  ];

  # Ensure composer directories exist and initialize composer.json
  home.activation.initComposer = lib.hm.dag.entryAfter ["writeBoundary"] ''
    COMPOSER_HOME="${config.xdg.configHome}/composer"
    REPO_COMPOSER="${config.home.homeDirectory}/nixos-system/composer.json"

    mkdir -p "$COMPOSER_HOME"

    # If neither file exists, create initial composer.json
    if [ ! -f "$COMPOSER_HOME/composer.json" ] && [ ! -f "$REPO_COMPOSER" ]; then
      cat > "$COMPOSER_HOME/composer.json" << 'EOF'
{
    "require": {}
}
EOF
    fi

    # Create hard link between repo and composer home if not already linked
    if [ -f "$COMPOSER_HOME/composer.json" ] && [ ! -f "$REPO_COMPOSER" ]; then
      ln "$COMPOSER_HOME/composer.json" "$REPO_COMPOSER"
    elif [ -f "$REPO_COMPOSER" ] && [ ! -f "$COMPOSER_HOME/composer.json" ]; then
      ln "$REPO_COMPOSER" "$COMPOSER_HOME/composer.json"
    fi
  '';

  # Add composer bin to PATH
  home.sessionPath = [
    "${config.xdg.configHome}/composer/vendor/bin"
  ];
}
