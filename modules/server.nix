# Generic headless-server concerns: shared by any non-desktop host.
{ ... }:
{
  networking.nftables.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.fail2ban.enable = true;

  # SSH access is already key-gated (password auth + root login disabled above),
  # so requiring a second password for sudo doesn't add meaningful security here.
  security.sudo.wheelNeedsPassword = false;

  # netcup VPS run under KVM - lets the hypervisor query guest status/time-sync
  services.qemuGuest.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
