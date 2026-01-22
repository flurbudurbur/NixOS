{ config, pkgs, ... }:

{
  home.packages = [
    (pkgs.callPackage ../../modules/custom/rpgmaker-linux {})
  ];

  xdg.desktopEntries.rpgmaker-linux = {
    name = "RPG Maker Linux";
    genericName = "Game Launcher";
    exec = "rpgmaker-linux %F";
    terminal = false;
    categories = [ "Game" "Utility" ];
    comment = "Launch RPG Maker and other compatible games natively on Linux";
    icon = "applications-games";
    mimeType = [ "application/x-rpgmaker" ];
  };
}
