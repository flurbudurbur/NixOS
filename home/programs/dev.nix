{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fnm
    pnpm
    nodePackages.prettier
    prettierd
    eslint_d
    blade-formatter
  ];
}
