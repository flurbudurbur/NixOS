# netcup VPS - provisioned via nixos-anywhere + disko.
#
# TODO before first install: boot the netcup rescue system and check
# `[ -d /sys/firmware/efi ]`. If it exists, switch to systemd-boot below;
# if not, GRUB legacy (the current default) is correct. Also confirm the
# disk device name in ./disko.nix matches `lsblk` output (usually /dev/vda
# for netcup's KVM plans).
{ ... }:
{
  imports = [
    ./disko.nix
    ../../modules/base.nix
    ../../modules/server.nix
    ../../modules/secrets.nix
    ./services/caddy.nix
    ./services/searxng.nix
    ./services/syncyomi.nix
    ./services/flur34.nix
  ];

  # boot.loader.grub.devices is supplied by disko (see disko.nix's EF02 partition)
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
  };

  # KVM/virtio guest kernel modules (netcup runs standard KVM)
  boot.initrd.availableKernelModules = [
    "ahci"
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-guest" ];

  networking.hostName = "vps";
  networking.useDHCP = true;

  system.stateVersion = "25.11";
}
