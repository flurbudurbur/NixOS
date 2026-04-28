{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/graphics.nix
    ../../modules/desktop.nix
    ../../modules/gaming.nix
    ../../modules/secrets.nix
    ../../modules/keyd.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Load USB HID and hub drivers early so keyboard works during initrd
  # NVIDIA modules loaded early for Plymouth KMS rendering
  boot.initrd.kernelModules = [
    "usbhid"
    "xhci_hcd"
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  # NVIDIA suspend/resume kernel parameters
  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "quiet"
    "splash"
    "loglevel=3"
    "rd.udev.log_level=3"
    "vt.global_cursor_default=0"
  ];

  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.plymouth.enable = true;

  # Networking
  networking.hostName = "flurPC";
  networking.networkmanager.enable = true;
  networking.interfaces.enp4s0.wakeOnLan.enable = true;

  system.stateVersion = "25.11";
}
