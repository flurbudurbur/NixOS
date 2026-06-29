{ hostname, lib }:

let
  monitorConfigs = {
    flurPC = [
      {
        output = "DP-2";
        mode = "2560x1440@165";
        position = "2560x0";
        scale = "1";
      }
      {
        output = "DP-1";
        mode = "2560x1440@165";
        position = "0x0";
        scale = "1";
      }
      {
        output = "DP-1";
        reserved = {
          top = 0;
          right = 0;
          bottom = 0;
          left = 55;
        };
      }
    ];
  };

  monitors =
    monitorConfigs.${hostname} or [
      {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = "auto";
      }
    ];

  parsePos =
    pos:
    let
      parts = lib.splitString "x" pos;
    in
    {
      x = lib.toInt (builtins.head parts);
      y = lib.toInt (builtins.elemAt parts 1);
    };

  sortedMonitors = map (m: m.output) (
    lib.sort (
      a: b:
      let
        pa = parsePos a.position;
        pb = parsePos b.position;
      in
      if pa.x != pb.x then pa.x < pb.x else pa.y < pb.y
    ) (builtins.filter (m: m ? position && m ? output && m.position != "auto") monitors)
  );
in
{
  inherit monitors sortedMonitors;
  primaryMonitor = builtins.head sortedMonitors;
  monitorCase = lib.concatStringsSep "\n" (
    lib.imap0 (i: name: ''"${name}") MON_IDX=${toString i} ;;'') sortedMonitors
  );
}
