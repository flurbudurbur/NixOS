# netcup VPS - provisioned via nixos-anywhere + disko.
#
# UEFI - requires the "EFI Boot" toggle enabled in the netcup panel before
# booting the rescue system (it defaults to Legacy BIOS otherwise).
{
  imports = [
    ./disko.nix
    ../../modules/base.nix
    ../../modules/server.nix
    ../../modules/secrets.nix
    ../../modules/relay.nix
    ./services/caddy.nix
    ./services/syncyomi.nix
    ./services/flur34.nix
    ./services/egress-proxy.nix
    ./services/forgejo-backup.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # flur deploys here via `nixos-rebuild --target-host` from the desktop, which
  # copies unsigned store paths - trusted users skip the signature check.
  nix.settings.trusted-users = [
    "root"
    "flur"
  ];

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
