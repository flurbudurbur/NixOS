{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fnm
    pnpm
    nodePackages.prettier
    prettierd
    eslint_d
    php83
    php83Packages.composer
    blade-formatter
  ];
}
