{ config, pkgs, ... }:

let
  c = import ./colors.nix;
in
{
  home.packages = [ pkgs.fastfetch ];

  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json",
      "logo": {
        "type": "builtin",
        "source": "NixOS"
      },
      "modules": [
        "title",
        "separator",
        "os",
        "kernel",
        "uptime",
        "packages",
        "shell",
        "terminal",
        "separator",
        "wm",
        "theme",
        "icons",
        "cursor",
        "separator",
        "cpu",
        "gpu",
        "memory",
        "separator",
        "colors"
      ]
    }
  '';
}
