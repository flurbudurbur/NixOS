{ pkgs, ... }:
{
  # System-level gaming: Steam, gamemode, and core Wine runtime
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  # Xbox controller support (xone driver from nixpkgs-unstable)
  # Handles blacklisting xpad/mt76x2u and includes wireless dongle firmware
  hardware.xone.enable = true;

  # Core gaming packages (available system-wide)
  environment.systemPackages = with pkgs; [
    # Wine with Wayland support (for Hyprland compatibility)
    wineWow64Packages.waylandFull
    winetricks
  ];
}
