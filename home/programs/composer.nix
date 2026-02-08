{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    php
    phpPackages.composer
  ];

  # Ensure composer directories exist and initialize composer.json
  home.activation.initComposer = lib.hm.dag.entryAfter ["writeBoundary"] ''
    COMPOSER_HOME="${config.xdg.configHome}/composer"

    mkdir -p "$COMPOSER_HOME"

    if [ ! -f "$COMPOSER_HOME/composer.json" ]; then
      cat > "$COMPOSER_HOME/composer.json" << 'EOF'
{
    "require": {}
}
EOF
    fi
  '';

  # Add composer bin to PATH
  home.sessionPath = [
    "${config.xdg.configHome}/composer/vendor/bin"
  ];
}
