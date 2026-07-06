# Declarative disk layout for nixos-anywhere.
#
# UEFI - enabled via the netcup panel's "EFI Boot" toggle (the rescue system
# reported Legacy BIOS before that was flipped). systemd-boot in ./default.nix,
# no legacy BIOS-boot partition needed.
{
  disko.devices = {
    disk.main = {
      device = "/dev/vda"; # confirmed via `lsblk` on the rescue system
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
