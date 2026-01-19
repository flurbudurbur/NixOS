{ ... }:
{
  imports = [
    ../../home/core.nix
    ../../home/programs
    ../../home/shell
    ../../home/wayland
    # Re-enabled after age migration
    ../../home/secrets.nix
  ];
}
