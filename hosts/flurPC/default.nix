{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/graphics.nix
    ../../modules/desktop.nix
    ../../modules/gaming.nix
    ../../modules/secrets.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Load USB HID and hub drivers early so keyboard works during initrd
  boot.initrd.kernelModules = [ "usbhid" "xhci_hcd" ];

  # NVIDIA suspend/resume kernel parameters
  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  # Networking
  networking.hostName = "flurPC";
  networking.networkmanager.enable = true;
  networking.interfaces.enp4s0.wakeOnLan.enable = true;

  system.stateVersion = "25.11";
}
