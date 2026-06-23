{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    php
    phpPackages.composer
  ];

  # Ensure composer directories exist and initialize composer.json with robust hard-linking
  home.activation.initComposer = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        COMPOSER_HOME="${config.xdg.configHome}/composer"
        COMPOSER_JSON="$COMPOSER_HOME/composer.json"

        # Detect repo location using git
        REPO_ROOT=$(${pkgs.git}/bin/git -C "${config.home.homeDirectory}" rev-parse --show-toplevel 2>/dev/null || echo "")
        if [ -n "$REPO_ROOT" ]; then
          REPO_COMPOSER="$REPO_ROOT/dotfiles/composer.json"
        else
          # Fallback if git detection fails
          REPO_COMPOSER="${config.home.homeDirectory}/nixos-system/dotfiles/composer.json"
        fi

        mkdir -p "$COMPOSER_HOME"

        # Handle all scenarios for hard-linking
        if [ -f "$COMPOSER_JSON" ] && [ -f "$REPO_COMPOSER" ]; then
          # Both exist - check if already hard-linked
          INODE1=$(stat -c %i "$COMPOSER_JSON")
          INODE2=$(stat -c %i "$REPO_COMPOSER")

          if [ "$INODE1" != "$INODE2" ]; then
            # Different files - backup composer home and link to repo (repo wins)
            TIMESTAMP=$(date +%Y%m%d_%H%M%S)
            mv "$COMPOSER_JSON" "$COMPOSER_JSON.backup-$TIMESTAMP"
            ln "$REPO_COMPOSER" "$COMPOSER_JSON"
            echo "Backed up existing composer.json to $COMPOSER_JSON.backup-$TIMESTAMP"
          fi
          # else: already linked, do nothing

        elif [ -f "$COMPOSER_JSON" ] && [ ! -f "$REPO_COMPOSER" ]; then
          # Only composer home exists - link repo to it
          ln "$COMPOSER_JSON" "$REPO_COMPOSER"

        elif [ ! -f "$COMPOSER_JSON" ] && [ -f "$REPO_COMPOSER" ]; then
          # Only repo exists - link composer home to it
          ln "$REPO_COMPOSER" "$COMPOSER_JSON"

        else
          # Neither exists - create in repo first, then link
          cat > "$REPO_COMPOSER" << 'EOF'
    {
        "require": {}
    }
    EOF
          ln "$REPO_COMPOSER" "$COMPOSER_JSON"
        fi
  '';

  # Add composer bin to PATH
  home.sessionPath = [
    "${config.xdg.configHome}/composer/vendor/bin"
  ];
}
