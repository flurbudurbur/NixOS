{ pkgs, firefox-addons, ... }:

{
  programs.zen-browser = {
    enable = true;

    policies = {
      AutofillAddressEnabled = true;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      OfferToSaveLoginsDefault = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DNSOverHTTPS = {
        Enabled = true;
        ProviderURL = "https://dns.nextdns.io/aef3c6";
        Locked = true;
        ExcludedDomains = [""];
        Fallback = true;
      };
      HttpsOnlyMode = "enabled";

      # Auto-enable all extensions
      ExtensionSettings = {
        "*" = {
          installation_mode = "normal_installed";
        };
      };
    };

    profiles.default = {
      isDefault = true;

      search = {
        force = true;
        default = "ddg";
        engines = {
          nixpkgs = {
            name = "NixPKGS";
            urls = [{
              template = "https://search.nixos.org/packages?channel=25.11&query={searchTerms}";
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nx" "@nixos" ];
          };
          nixOptions = {
            name = "Options";
            urls = [{
              template = "https://search.nixos.org/options?channel=25.11&query={searchTerms}";
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@options" "@op" ];
          };
          srxFlurDev = {
            name = "srx";
            urls = [{
              template = "https://srx.flur.dev/search?q={searchTerms}";
            }];
            icon = "🔍";
            definedAliases = [ "@srx" ];
          };
          "youtube" = {
            name = "YouTube";
            urls = [{
              template = "https://youtube.com/search?q={searchTerms}";
            }];
            icon = "🎧";
            definedAliases = [ "@yt" "@youtube" ];
          };
        };
      };

      # Spaces (workspaces)
      # Generate UUIDs with: uuidgen | tr '[:upper:]' '[:lower:]'
      spacesForce = true;
      spaces = {
        "Personal" = {
          id = "428ffc5e-ba75-4401-836c-bfc921ff6a98";
          position = 1000;
          icon = "🦄";
          theme = {
            type = "gradient";
            colors = [
              { red = 235; green = 111; blue = 146; }  # Rose Pine rose
            ];
            opacity = 0.35;
            texture = 0.5;
          };
        };
      };

      # Pinned tabs
      pinsForce = true;
      pins = {
        "Qobuz" = {
          id = "1aa50237-dccb-4840-b576-486d0e66278f";
          url = "https://play.qobuz.com/discover";
          workspace = "428ffc5e-ba75-4401-836c-bfc921ff6a98";
          isEssential = true;
          position = 100;
        };
        "Proton Mail" = {
          id = "d4ea7b42-9e79-4466-a5ed-ebb8ca0fca48";
          url = "https://mail.proton.me/";
          workspace = "428ffc5e-ba75-4401-836c-bfc921ff6a98";
          isEssential = true;
          position = 101;
        };
        "GitHub" = {
          id = "69e2a131-7dea-44fd-8246-a0fbc40fa125";
          url = "https://github.com/flurbudurbur";
          workspace = "428ffc5e-ba75-4401-836c-bfc921ff6a98";
          isEssential = true;
          position = 102;
        };
        "Claude" = {
          id = "1f9afd1f-8e19-4597-a07d-aba7f5312f34";
          url = "https://claude.ai/";
          workspace = "428ffc5e-ba75-4401-836c-bfc921ff6a98";
          isEssential = true;
          position = 103;
        };
        "LinkedIn" = {
          id = "59a8d539-d5c4-4b18-959a-f031c0fbbabe";
          url = "https://www.linkedin.com/jobs/";
          workspace = "428ffc5e-ba75-4401-836c-bfc921ff6a98";
          position = 104;
        };
        "NixCord" = {
          id = "08adc110-c4aa-4443-9fd6-0c3b4de5ef9f";
          url = "https://github.com/FlameFlag/nixcord";
          workspace = "428ffc5e-ba75-4401-836c-bfc921ff6a98";
          position = 105;
        };
      };

      extensions.packages = with firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        ublock-origin
        darkreader
        proton-pass
        decentraleyes
      ];

      settings = {
        # Browser behavior
        browser = {
          tabs.warnOnClose = false;
          download.panel.shown = false;
          translations = {
            enable = false;
            automaticallyPopup = false;
          };
        };

        # Auto-enable extensions
        extensions = {
          autoDisableScopes = 0;
          enabledScopes = 15;
        };

        # Enable custom CSS
        toolkit = {
          legacyUserProfileCustomizations.stylesheets = true;
          telemetry = {
            enabled = false;
            unified = false;
            archive.enabled = false;
          };
        };

        # DNS over HTTPS - Max Protection
        network.trr.mode = 3;

        # Privacy settings
        privacy = {
          donottrackheader.enabled = true;
          trackingprotection = {
            enabled = true;
            socialtracking.enabled = true;
          };
        };

        # Disable telemetry
        datareporting = {
          healthreport.uploadEnabled = false;
          policy.dataSubmissionEnabled = false;
        };

        # Zen Browser specific
        zen.view.window.scheme = 0;
      };
    };
  };
}
