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
    prettier
    prettierd
    eslint_d
    blade-formatter
    nixpkgs-unstable.devenv
    gradle_9
    podman-compose
    gh
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk25;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
