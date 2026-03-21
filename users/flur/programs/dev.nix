{
  pkgs,
  nixpkgs-unstable,
  ...
}:
{
  home.packages = with pkgs; [
    fnm
    pnpm
    nodejs_24
    nodePackages.prettier
    prettierd
    eslint_d
    blade-formatter
    nixpkgs-unstable.devenv
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    stdlib = ''
      eval "$(devenv direnvrc)"
    '';
  };
}
