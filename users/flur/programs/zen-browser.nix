{
  pkgs,
  firefox-addons,
  config,
  lib,
  ...
}:

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
        ProviderURL = "@NEXTDNS_URL@";
        Locked = true;
        ExcludedDomains = [ "" ];
        Fallback = true;
      };
      HttpsOnlyMode = "enabled";

      # Auto-enable all extensions
      ExtensionSettings."*".installation_mode = "normal_installed";
    };

    profiles.default =
      let
        # Containers for tab isolation
        containers = {
          Personal = {
            color = "pink";
            icon = "fingerprint";
            id = 1;
          };
          School = {
            color = "red";
            icon = "dollar";
            id = 2;
          };
        };

        # Spaces (workspaces)
        # Generate UUIDs with: uuidgen | tr '[:upper:]' '[:lower:]'
        spaces = {
          "Personal" = {
            id = "428ffc5e-ba75-4401-836c-bfc921ff6a98";
            position = 1000;
            icon = "🦄";
            container = containers.Personal.id;
          };
          "School" = {
            id = "84a04875-594d-4c9f-b011-a6ac1bbd3147";
            position = 1001;
            icon = "🎓";
            container = containers.School.id;
          };
        };

        inSpace = space: { workspace = space.id; container = space.container; };
        pinsIn = space: ps: lib.mapAttrs (_: pin: pin // inSpace space) ps;

        # Pinned tabs
        pins =
          pinsIn spaces.Personal {
            "Qobuz" = {
              id = "1aa50237-dccb-4840-b576-486d0e66278f";
              url = "https://play.qobuz.com/discover";
              isEssential = true;
              position = 100;
            };
            "Proton Mail" = {
              id = "d4ea7b42-9e79-4466-a5ed-ebb8ca0fca48";
              url = "https://mail.proton.me/";
              isEssential = true;
              position = 101;
            };
            "GitHub" = {
              id = "69e2a131-7dea-44fd-8246-a0fbc40fa125";
              url = "https://github.com/flurbudurbur";
              isEssential = true;
              position = 102;
            };
            "Claude" = {
              id = "1f9afd1f-8e19-4597-a07d-aba7f5312f34";
              url = "https://claude.ai/";
              isEssential = true;
              position = 103;
            };
            "Fluxer" = {
              id = "e7a1f674-8f7d-40f4-93da-e46ffe86bd33";
              url = "https://web.fluxer.app/channels/@me/";
              position = 104;
            };
            "LinkedIn" = {
              id = "59a8d539-d5c4-4b18-959a-f031c0fbbabe";
              url = "https://www.linkedin.com/jobs/";
              position = 114;
            };
            "iTheorie" = {
              id = "64fd5477-01e6-45e3-a761-4119bc8b7e2d";
              url = "https://itheorie.nl/";
              position = 115;
            };
          } //
          pinsIn spaces.School {
            "Canvas" = {
              id = "46a1c942-8f78-4471-b720-fcb1c99cc016";
              url = "https://canvas.hu.nl/";
              isEssential = true;
              position = 100;
            };
            "Outlook" = {
              id = "5fe18b16-ef8a-4a69-9ee8-350ef5714246";
              url = "https://outlook.cloud.microsoft";
              isEssential = true;
              position = 101;
            };
            "Teams" = {
              id = "ea614fe0-b8a4-46d9-a99d-60b227a59843";
              url = "https://teams.microsoft.com/";
              isEssential = true;
              position = 102;
            };
            "Osiris" = {
              id = "169ba356-1701-4ac3-9fd4-b1158b90dad0";
              url = "https://hu.osiris-student.nl/home";
              position = 110;
            };
            "Wegwijs" = {
              id = "85dd872c-6f7c-4372-9aaa-a80f919b6919";
              url = "https://huenik.hu.nl/";
              position = 111;
            };
          };
      in
      {
        isDefault = true;

        containersForce = true;
        spacesForce = true;
        pinsForce = true;
        inherit containers spaces pins;

        search = {
          force = true;
          default = "ddg";
          engines = {
            nixpkgs = {
              name = "NixPKGS";
              urls = [
                {
                  template = "https://search.nixos.org/packages?channel=25.11&query={searchTerms}";
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [
                "@nx"
                "@nixos"
              ];
            };
            nixOptions = {
              name = "Options";
              urls = [
                {
                  template = "https://search.nixos.org/options?channel=25.11&query={searchTerms}";
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [
                "@options"
                "@op"
              ];
            };
            srxFlurDev = {
              name = "srx";
              urls = [
                {
                  template = "https://srx.flur.dev/search?q={searchTerms}";
                }
              ];
              icon = "🔍";
              definedAliases = [ "@srx" ];
            };
            "youtube" = {
              name = "YouTube";
              urls = [
                {
                  template = "https://youtube.com/search?q={searchTerms}";
                }
              ];
              icon = "🎧";
              definedAliases = [
                "@yt"
                "@youtube"
              ];
            };
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

  # Substitute secret at activation
  home.activation.substituteZenBrowserSecrets = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f "${config.xdg.configHome}/sops-secrets/nextdns-url" ]; then
      NEXTDNS_URL=$(cat "${config.xdg.configHome}/sops-secrets/nextdns-url")

      POLICIES_DIR="$HOME/.zen"
      if [ -d "$POLICIES_DIR" ]; then
        find "$POLICIES_DIR" -type f \( -name "*.js" -o -name "*.json" \) | while read file; do
          sed -i "s|@NEXTDNS_URL@|$NEXTDNS_URL|g" "$file" 2>/dev/null || true
        done
      fi
    fi
  '';
}
