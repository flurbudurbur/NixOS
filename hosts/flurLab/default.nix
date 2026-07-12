# Homelab PC (ex-Windows box) - provisioned via nixos-anywhere + disko.
# UEFI, Samsung 128GB NVMe (OS) + HGST 1TB SATA (data).
{ lib, ... }:
{
  imports = [
    ./disko.nix
    ../../modules/base.nix
    ../../modules/server.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  hardware.enableRedistributableFirmware = true;

  # Physical machine, not a KVM guest (server.nix enables this for the vps)
  services.qemuGuest.enable = lib.mkForce false;

  nix.settings.trusted-users = [
    "root"
    "flur"
  ];

  networking.hostName = "flurLab";
  networking.useDHCP = true;

  system.stateVersion = "25.11";
}
