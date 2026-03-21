{ pkgs, ... }:
{
  services.flatpak.packages = [
    {
      appId = "app.fluxer.Fluxer";
      origin = "flathub";
    }
  ];

  # Service to install/update Hytale launcher from remote .flatpak file
  systemd.user.services.install-hytale-launcher = {
    Unit = {
      Description = "Install Hytale Launcher Flatpak";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "install-hytale" ''
        set -euo pipefail

        FLATPAK_URL="https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-latest.flatpak"
        TEMP_FILE=$(${pkgs.coreutils}/bin/mktemp --suffix=.flatpak)
        trap '${pkgs.coreutils}/bin/rm -f "$TEMP_FILE"' EXIT

        ${pkgs.curl}/bin/curl -fsSL -o "$TEMP_FILE" "$FLATPAK_URL"
        ${pkgs.flatpak}/bin/flatpak install -y --bundle --user "$TEMP_FILE"
      '';
    };
  };

  # Timer to check for updates daily
  systemd.user.timers.install-hytale-launcher = {
    Unit.Description = "Check for Hytale Launcher updates";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
