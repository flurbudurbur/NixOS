{ schemes }:
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

  validate =
    name: theme:
    let
      missing = builtins.filter (attr: !(builtins.hasAttr attr theme)) requiredAttrs;
    in
    if missing == [ ] then
      theme
    else
      throw "Theme '${name}' is missing attributes: ${builtins.concatStringsSep ", " missing}";

  themeList = import ./themes.nix;

  parseScheme = import ./parse-scheme.nix;

  resolvePath =
    name:
    let
      b24 = "${schemes}/base24/${name}.yaml";
      b16 = "${schemes}/base16/${name}.yaml";
    in
    if builtins.pathExists b24 then b24 else b16;

  loadColors =
    name:
    let
      customFile = ./. + "/${name}.nix";
    in
    if builtins.pathExists customFile then import customFile else parseScheme (resolvePath name);

  mkTheme =
    { theme, icon }:
    {
      name = theme;
      value = (validate theme (loadColors theme)) // { inherit icon; };
    };
in
builtins.listToAttrs (map mkTheme themeList)
