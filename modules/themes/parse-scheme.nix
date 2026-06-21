yamlPath:
let
  content = builtins.readFile yamlPath;
  lines = builtins.filter builtins.isString (builtins.split "\n" content);

  paletteLines = builtins.filter (
    l: builtins.match "^  base[0-9A-Fa-f]+:.*" l != null
  ) lines;

  parseLine =
    l:
    let
      m = builtins.match ''[ ]+(base[0-9A-Fa-f]+): *"?(#[0-9a-fA-F]{6})"?.*'' l;
    in
    {
      name = builtins.elemAt m 0;
      value = builtins.elemAt m 1;
    };

  palette = builtins.listToAttrs (builtins.map parseLine paletteLines);
in
{
  bg = palette.base00;
  bg_alt = palette.base01;
  bg_select = palette.base02;
  fg_faint = palette.base03;
  fg_dim = palette.base04;
  fg = palette.base05;
  error = palette.base08;
  warning = palette.base09;
  accent2 = palette.base0A;
  cyan = palette.base0C;
  blue = palette.base0D;
  accent = palette.base0E;
  hl_low = palette.base01;
  hl_med = palette.base02;
  hl_high = palette.base03;
}
