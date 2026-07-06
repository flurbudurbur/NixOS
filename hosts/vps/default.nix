# netcup VPS - provisioned via nixos-anywhere + disko.
#
# UEFI - requires the "EFI Boot" toggle enabled in the netcup panel before
# booting the rescue system (it defaults to Legacy BIOS otherwise).
{ pkgs, ... }:
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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # SSH/SFTP-only account for uploading music files - no service runs as this user.
  users.users.music = {
    isNormalUser = true;
    home = "/srv/music";
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnpkT52t3MkXqJUEWAeWRyHXlTNrgIpGy+A12wkJm5s music@v2202512321715414857"
    ];
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
