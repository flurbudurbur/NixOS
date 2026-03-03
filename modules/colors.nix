# colors.nix - Rose Pine Moon theme
# Central color definitions for all NixOS configuration files
rec {
  # Main palette
  base = "#232136";
  surface = "#2a273f";
  overlay = "#393552";
  muted = "#6e6a86";
  subtle = "#908caa";
  text = "#e0def4";
  love = "#eb6f92";
  gold = "#f6c177";
  rose = "#ea9a97";
  pine = "#3e8fb0";
  foam = "#9ccfd8";
  iris = "#c4a7e7";
  highlightLow = "#2a283e";
  highlightMed = "#44415a";
  highlightHigh = "#56526e";

  # Terminal ANSI colors
  ansi = {
    black = overlay;
    red = love;
    green = pine;
    yellow = gold;
    blue = foam;
    magenta = iris;
    cyan = rose;
    white = text;
    brightBlack = muted;
    brightRed = love;
    brightGreen = pine;
    brightYellow = gold;
    brightBlue = foam;
    brightMagenta = iris;
    brightCyan = rose;
    brightWhite = text;
  };

  # Helper functions
  strip = hex: builtins.substring 1 6 hex;

  # Hyprland format: rgba(232136ee)
  hypr = hex: alpha: "rgba(${strip hex}${alpha})";

  # CSS rgba with decimal alpha: rgba(35, 33, 54, 0.9)
  rgba =
    hex: alpha:
    let
      hexToInt =
        h:
        let
          chars = {
            "0" = 0;
            "1" = 1;
            "2" = 2;
            "3" = 3;
            "4" = 4;
            "5" = 5;
            "6" = 6;
            "7" = 7;
            "8" = 8;
            "9" = 9;
            "a" = 10;
            "b" = 11;
            "c" = 12;
            "d" = 13;
            "e" = 14;
            "f" = 15;
          };
          c1 = builtins.substring 0 1 h;
          c2 = builtins.substring 1 1 h;
        in
        chars.${c1} * 16 + chars.${c2};
      r = hexToInt (builtins.substring 1 2 hex);
      g = hexToInt (builtins.substring 3 2 hex);
      b = hexToInt (builtins.substring 5 2 hex);
    in
    "rgba(${toString r}, ${toString g}, ${toString b}, ${alpha})";

  # RGB format for hyprlock: rgb(35, 33, 54)
  rgb =
    hex:
    let
      hexToInt =
        h:
        let
          chars = {
            "0" = 0;
            "1" = 1;
            "2" = 2;
            "3" = 3;
            "4" = 4;
            "5" = 5;
            "6" = 6;
            "7" = 7;
            "8" = 8;
            "9" = 9;
            "a" = 10;
            "b" = 11;
            "c" = 12;
            "d" = 13;
            "e" = 14;
            "f" = 15;
          };
          c1 = builtins.substring 0 1 h;
          c2 = builtins.substring 1 1 h;
        in
        chars.${c1} * 16 + chars.${c2};
      r = hexToInt (builtins.substring 1 2 hex);
      g = hexToInt (builtins.substring 3 2 hex);
      b = hexToInt (builtins.substring 5 2 hex);
    in
    "rgb(${toString r}, ${toString g}, ${toString b})";
}
