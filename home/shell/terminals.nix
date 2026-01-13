{ pkgs, ... }:
let
  c = import ../../modules/colors.nix;
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell = "${pkgs.zsh}/bin/zsh";
      font = {
        normal = {
          family = "FiraCode Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "FiraCode Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "FiraCode Nerd Font";
          style = "Italic";
        };
        size = 12;
      };
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        opacity = 0.95;
      };
      colors = {
        primary = {
          foreground = c.text;
          background = c.base;
        };
        cursor = {
          text = c.text;
          cursor = c.highlightHigh;
        };
        selection = {
          text = c.text;
          background = c.highlightMed;
        };
        normal = {
          black = c.ansi.black;
          red = c.ansi.red;
          green = c.ansi.green;
          yellow = c.ansi.yellow;
          blue = c.ansi.blue;
          magenta = c.ansi.magenta;
          cyan = c.ansi.cyan;
          white = c.ansi.white;
        };
        bright = {
          black = c.ansi.brightBlack;
          red = c.ansi.brightRed;
          green = c.ansi.brightGreen;
          yellow = c.ansi.brightYellow;
          blue = c.ansi.brightBlue;
          magenta = c.ansi.brightMagenta;
          cyan = c.ansi.brightCyan;
          white = c.ansi.brightWhite;
        };
      };
    };
  };
}
