{ config, pkgs, ... }:
{
  # Enable Flatpak support
  services.flatpak.enable = true;

  # Declarative Flatpak package management
  services.flatpak = {
    # Auto-update packages
    update.auto = {
      enable = true;
      onCalendar = "weekly"; # Run updates weekly
    };

    # Uninstall packages not managed by nix-flatpak
    uninstallUnmanaged = false; # Set to false to allow manual .flatpak installs

    # Configure remotes
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    # Packages to install from Flathub
    packages = [
      # Add your Flatpak packages here
      # Example: "com.spotify.Client"
    ];
  };

  # Service to install Hytale launcher from remote .flatpak file
  systemd.user.services.install-hytale-launcher = {
    Unit = {
      Description = "Install Hytale Launcher Flatpak";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "install-hytale" ''
        FLATPAK_URL="https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-latest.flatpak"
        TEMP_FILE=$(${pkgs.coreutils}/bin/mktemp --suffix=.flatpak)

        # Download the latest version
        ${pkgs.curl}/bin/curl -L -o "$TEMP_FILE" "$FLATPAK_URL"

        # Install or update if not already installed
        if ! ${pkgs.flatpak}/bin/flatpak list --app | grep -q "com.hytale.launcher"; then
          ${pkgs.flatpak}/bin/flatpak install -y --bundle --user "$TEMP_FILE"
        fi

        # Cleanup
        ${pkgs.coreutils}/bin/rm -f "$TEMP_FILE"
      '';
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
