{ pkgs, ... }:

let
  icons = import ./icons.nix { };

  bar = import ./bar.nix { inherit pkgs; };
  clock = import ./clock.nix { };
  workspaces = import ./workspaces.nix { inherit pkgs icons; };
  volume = import ./volume.nix { };
  network = import ./network.nix { inherit pkgs icons; };
  cpu = import ./cpu.nix { inherit icons; };
  memory = import ./memory.nix { inherit icons; };

  components = [
    bar
    clock
    workspaces
    volume
    network
    cpu
    memory
  ];
in
{
  programs.eww = {
    enable = true;
    package = pkgs.eww;
  };

  home.packages = [
    pkgs.jq
    pkgs.socat
  ];

  xdg.configFile."eww/eww.scss".text = builtins.concatStringsSep "\n" (map (c: c.scss) components);
  xdg.configFile."eww/eww.yuck".text = builtins.concatStringsSep "\n" (map (c: c.yuck) components);

  systemd.user.services.bar = {
    Unit = {
      Description = "Status bar";
      Documentation = "https://elkowar.github.io/eww/";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${bar.startScript}";
      Restart = "on-failure";
      RestartSec = "3s";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
