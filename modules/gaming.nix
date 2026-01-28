{ pkgs, ... }:
{
  # System-level gaming: Steam, gamemode, and core Wine runtime
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  # Core gaming packages (available system-wide)
  environment.systemPackages = with pkgs; [
    # Wine with Wayland support (for Hyprland compatibility)
    wineWowPackages.waylandFull
    winetricks
  ];
}
