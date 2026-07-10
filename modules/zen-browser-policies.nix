# Zen Browser's policies.json (Firefox enterprise policy engine) is baked
# into the immutable, systemwide wrapFirefox derivation at build time, so it
# can't carry a runtime secret the way ~/.ssh/config can via sops.templates +
# Include. This build has MOZ_SYSTEM_POLICIES compiled in, and per Mozilla's
# own docs, real Firefox checks /etc/${MOZ_APP_NAME}/policies/policies.json
# (e.g. /etc/firefox/policies/policies.json) *first* - used exclusively, not
# merged with the bundled one - before falling back to distribution/. Zen's
# MOZ_APP_NAME is "zen", but write to a couple of plausible vendor dirs since
# that naming isn't independently confirmed for this fork. Rendered via the
# system-level sops-nix (decrypts during early boot activation, before any
# user session exists - unlike the home-manager one, no "no session yet"
# race).
{ config, secretsPath, ... }:

let
  policiesContent = builtins.toJSON {
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
        ProviderURL = config.sops.placeholder."nextdns-url";
        Locked = true;
        ExcludedDomains = [ "" ];
        Fallback = true;
      };
      HttpsOnlyMode = "enabled";
      ExtensionSettings."*".installation_mode = "normal_installed";
    };
  };

  candidateVendorDirs = [
    "zen"
    "zen-browser"
    "firefox"
  ];
in
{
  sops.secrets."nextdns-url" = {
    sopsFile = "${secretsPath}/user/nextdns.yaml";
  };

  sops.templates = builtins.listToAttrs (
    map (vendor: {
      name = "zen-policies-json-${vendor}";
      value = {
        path = "/etc/${vendor}/policies/policies.json";
        mode = "0444";
        content = policiesContent;
      };
    }) candidateVendorDirs
  );
}
