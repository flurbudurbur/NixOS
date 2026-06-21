let
  requiredAttrs = [
    "bg"
    "bg_alt"
    "bg_select"
    "fg_faint"
    "fg_dim"
    "fg"
    "error"
    "warning"
    "accent2"
    "blue"
    "cyan"
    "accent"
    "hl_low"
    "hl_med"
    "hl_high"
  ];

  dir = builtins.readDir ./.;

  themeFiles = builtins.filter (
    name: name != "default.nix" && builtins.match ".*\\.nix" name != null
  ) (builtins.attrNames dir);

  themeName = fileName: builtins.substring 0 (builtins.stringLength fileName - 4) fileName;

  validate =
    name: theme:
    let
      missing = builtins.filter (attr: !(builtins.hasAttr attr theme)) requiredAttrs;
    in
    if missing == [ ] then
      theme
    else
      builtins.throw "Theme '${name}' is missing attributes: ${builtins.concatStringsSep ", " missing}";

  themes = builtins.listToAttrs (
    builtins.map (
      fileName:
      let
        name = themeName fileName;
        raw = import (./. + "/${fileName}");
      in
      {
        inherit name;
        value = validate name raw;
      }
    ) themeFiles
  );
in
themes
