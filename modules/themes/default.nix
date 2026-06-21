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
      builtins.throw "Theme '${name}' is missing attributes: ${builtins.concatStringsSep ", " missing}";

  # Custom .nix themes (auto-discovered)
  specialFiles = [
    "default.nix"
    "tinted.nix"
    "parse-scheme.nix"
  ];
  dir = builtins.readDir ./.;
  customFiles = builtins.filter (
    name: !(builtins.elem name specialFiles) && builtins.match ".*\\.nix" name != null
  ) (builtins.attrNames dir);

  themeName = fileName: builtins.substring 0 (builtins.stringLength fileName - 4) fileName;

  customThemes = builtins.listToAttrs (
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
    ) customFiles
  );

  # Tinted-theming schemes (parsed from YAML)
  parseScheme = import ./parse-scheme.nix;
  tintedNames = import ./tinted.nix;

  resolvePath =
    name:
    let
      b24 = "${schemes}/base24/${name}.yaml";
      b16 = "${schemes}/base16/${name}.yaml";
    in
    if builtins.pathExists b24 then b24 else b16;

  tintedThemes = builtins.listToAttrs (
    builtins.map (name: {
      inherit name;
      value = validate name (parseScheme (resolvePath name));
    }) tintedNames
  );
in
customThemes // tintedThemes
