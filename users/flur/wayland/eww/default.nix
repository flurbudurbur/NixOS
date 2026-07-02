{
  pkgs,
  hostname,
  lib,
  ...
}:

let
  icons = import ./icons.nix { };
  primaryMonitor = (import ../monitors.nix { inherit hostname lib; }).primaryMonitor;

  bar = import ./bar.nix { inherit pkgs; };
  clock = import ./clock.nix { };
  workspaces = import ./workspaces.nix { inherit pkgs icons primaryMonitor; };
  sesh = import ./sesh.nix { inherit pkgs; };
  volume = import ./volume.nix { inherit pkgs icons; };
  media = import ./media.nix { inherit pkgs icons; };
  network = import ./network.nix { inherit pkgs icons; };
  progressModule = import ./progress-module.nix { };
  cpu = import ./cpu.nix { inherit icons; };
  memory = import ./memory.nix { inherit icons; };
  vpn = import ./vpn.nix { inherit pkgs icons; };

  components = [
    bar
    clock
    workspaces
    sesh
    volume
    media
    network
    progressModule
    cpu
    memory
    vpn
  ];
in
{
  programs.eww = {
    enable = true;
    package = pkgs.eww;
  };

  home.packages = with pkgs; [
    jq
    socat
    playerctl
  ];

  xdg.configFile."eww/eww.scss" = {
    text = builtins.concatStringsSep "\n" (map (c: c.scss) components);
    onChange = "${pkgs.systemd}/bin/systemctl --user try-restart bar.service || true";
  };
  xdg.configFile."eww/eww.yuck" = {
    text = builtins.concatStringsSep "\n" (map (c: c.yuck) components);
    onChange = "${pkgs.systemd}/bin/systemctl --user try-restart bar.service || true";
  };

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
