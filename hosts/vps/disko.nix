# Declarative disk layout for nixos-anywhere.
#
# Includes both a BIOS-boot partition and an ESP so the same layout works
# whether the netcup rescue system reports legacy BIOS or UEFI - pick the
# matching loader in ./default.nix once you've confirmed which one it is
# (check for /sys/firmware/efi on the rescue system).
{
  disko.devices = {
    disk.main = {
      device = "/dev/vda"; # confirm the actual device name from `lsblk` on the rescue system
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02"; # BIOS boot partition, used by GRUB in legacy mode
          };
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
