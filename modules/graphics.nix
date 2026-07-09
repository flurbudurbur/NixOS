_: {
  # Hardware
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;

    # Enable power management (required for suspend/resume)
    powerManagement.enable = true;

    # Experimental feature: save/restore GPU state on suspend
    # This helps prevent GPU crashes after resume
    powerManagement.finegrained = false;
  };
}
