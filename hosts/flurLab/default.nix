# Homelab PC (ex-Windows box) - provisioned via nixos-anywhere + disko.
# UEFI, Samsung 128GB NVMe (OS) + HGST 1TB SATA (data).
{ lib, ... }:
{
  imports = [
    ./disko.nix
    ../../modules/base.nix
    ../../modules/server.nix
    ../../modules/secrets.nix
    ./services/wireguard.nix
    ./services/forgejo.nix
    ./services/searxng.nix
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

  # Forgejo's built-in SSH server (services/forgejo.nix) takes the conventional :22
  # for git clone URLs, so the host's own OpenSSH moves to :2222.
  services.openssh.ports = lib.mkForce [ 2222 ];
  networking.firewall.allowedTCPPorts = lib.mkForce [
    2222
    80
    443
  ];

  nix.settings.trusted-users = [
    "root"
    "flur"
  ];

  networking.hostName = "flurLab";
  networking.useDHCP = true;
  networking.interfaces.eno2.wakeOnLan.enable = true;

  system.stateVersion = "25.11";
}
