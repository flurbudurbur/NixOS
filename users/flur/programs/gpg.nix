{ pkgs, ... }:
{
  # Install packages for Yubikey and GPG
  home.packages = with pkgs; [
    pinentry-curses # Terminal fallback
    yubikey-manager # YubiKey management CLI (ykman)
    yubikey-personalization # YubiKey personalization tools
    pcsc-tools # PC/SC tools for smart card debugging
  ];

  # GPG program configuration
  programs.gpg = {
    enable = true;

    settings = {
      # Use strong cryptographic algorithms
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP";

      # Key display settings
      keyid-format = "0xlong";
      with-fingerprint = true;

      # Keyserver configuration
      keyserver = "hkps://keys.openpgp.org";

      # Privacy settings
      no-emit-version = true;
      no-comments = true;

      # Modern crypto defaults
      cert-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";
      s2k-digest-algo = "SHA512";

      # Smartcard/Yubikey specific settings
      use-agent = true;
    };

    # Configure scdaemon (smartcard daemon) for Yubikey
    scdaemonSettings = {
      disable-ccid = true;
      reader-port = "Yubico YubiKey";
    };
  };

  # GPG agent service configuration with smartcard support
  services.gpg-agent = {
    enable = true;
    enableSshSupport = false; # GNOME Keyring already handles SSH
    enableScDaemon = true; # Enable smartcard daemon for Yubikey

    # Cache configuration
    # Note: With Yubikey, caching is less important since you need physical touch anyway
    defaultCacheTtl = 3600; # 1 hour
    maxCacheTtl = 86400; # 24 hours

    # Pinentry configuration (GUI for Wayland/Hyprland)
    pinentry.package = pkgs.pinentry-gnome3;

    extraConfig = ''
      allow-loopback-pinentry
    '';
  };
}
