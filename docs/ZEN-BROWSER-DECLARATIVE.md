# Zen Browser Declarative Configuration

Reference for the fully declarative Zen Browser setup managed through Nix and home-manager.

## Flake Input

Zen Browser comes from the `0xc000022070/zen-browser-flake` GitHub flake. The home-manager module is imported as `inputs.zen-browser.homeModules.default` in `flake.nix`. This provides the `programs.zen-browser` option set, which extends Firefox's home-manager module with Zen-specific features (spaces, containers, pins).

## Configuration File

All browser configuration lives in `users/flur/programs/zen-browser.nix`.

## Policies

Browser policies are enforced at the application level (written to the profile's policy files). Key decisions:

- **DisableAppUpdate**: Zen is managed by Nix; app-level updates would conflict.
- **OfferToSaveLogins / OfferToSaveLoginsDefault**: Disabled because Proton Pass handles credentials.
- **AutofillCreditCardEnabled**: Disabled for security.
- **DNSOverHTTPS**: Enabled and locked to a NextDNS endpoint. The `ProviderURL` is set to the placeholder `@NEXTDNS_URL@` at build time and substituted with the real URL at activation time (see Secret Substitution below).
- **network.trr.mode = 3**: Max protection mode -- all DNS goes through DoH with no fallback to system DNS. Combined with the locked policy, this ensures DNS always routes through NextDNS.
- **EnableTrackingProtection**: Locked on with cryptomining and fingerprinting protection.
- **HttpsOnlyMode**: Enforced HTTPS.
- **ExtensionSettings.\***: All extensions auto-install as `normal_installed`.

## Containers

Containers provide tab isolation between browsing contexts. Each container has a numeric `id`, a `color`, and an `icon`:

| Container | ID | Purpose |
|-----------|------|---------|
| Personal  | 1    | Personal browsing |
| School    | 2    | School/university browsing |

The `containersForce = true` flag ensures the Nix-declared containers replace any manually created ones on each activation.

## Spaces (Workspaces)

Spaces are Zen Browser's workspace feature. Each space is bound to a container, so all tabs opened in that space are automatically isolated.

| Space    | Container | Icon | Position |
|----------|-----------|------|----------|
| Personal | Personal  | --   | 1000     |
| School   | School    | --   | 1001     |

Each space has a stable UUID (`id` field) used internally by Zen to track workspace membership.

`spacesForce = true` makes Nix the source of truth -- manual space changes are overwritten on rebuild.

### Generating Space/Pin UUIDs

UUIDs are arbitrary but must be stable across rebuilds (changing them would orphan associated tabs). Generate new ones with:

```bash
uuidgen | tr '[:upper:]' '[:lower:]'
```

## Pinned Tabs

Pinned tabs are declared per-space using the `pinsIn` helper, which automatically assigns the correct `workspace` and `container` IDs from the space definition.

### Personal Space Pins

| Name        | URL                                    | Essential | Position |
|-------------|----------------------------------------|-----------|----------|
| Qobuz       | play.qobuz.com/discover                | yes       | 100      |
| Proton Mail | mail.proton.me                         | yes       | 101      |
| GitHub      | github.com/flurbudurbur                | yes       | 102      |
| Claude      | claude.ai                              | yes       | 103      |
| Fluxer      | web.fluxer.app/channels/@me/           | no        | 104      |
| LinkedIn    | linkedin.com/jobs/                     | no        | 114      |
| NebulaTV    | nebula.tv                              | no        | 115      |

### School Space Pins

| Name    | URL                              | Essential | Position |
|---------|----------------------------------|-----------|----------|
| Canvas  | canvas.hu.nl                     | yes       | 100      |
| Outlook | outlook.cloud.microsoft          | yes       | 101      |
| Teams   | teams.microsoft.com              | yes       | 102      |
| Osiris  | hu.osiris-student.nl/home        | no        | 110      |
| Wegwijs | huenik.hu.nl                     | no        | 111      |

**Essential pins** (`isEssential = true`) are always visible in the sidebar. Non-essential pins can be hidden.

**Position** controls ordering within a space. Gaps between positions (100, 101, ... 110, 114) leave room for future insertions without renumbering.

`pinsForce = true` makes Nix authoritative -- manually pinned tabs are removed on rebuild.

## Extensions

Extensions are declared via `extensions.packages` using the `firefox-addons` flake input (rycee's NUR expressions). Current set:

- ublock-origin, darkreader, proton-pass, decentraleyes, sponsorblock, dearrow, privacy-badger, clearurls

Extensions are auto-enabled on install via:
- `extensions.autoDisableScopes = 0` (don't auto-disable any scope)
- `extensions.enabledScopes = 15` (enable all scopes: profile + user + application + system)

## Custom Search Engines

| Alias        | Name     | URL Pattern |
|-------------|----------|-------------|
| `@nx`, `@nixos` | NixPKGS  | search.nixos.org/packages |
| `@options`, `@op` | Options  | search.nixos.org/options |
| `@srx`      | srx      | srx.flur.dev/search |
| `@yt`, `@youtube` | YouTube  | youtube.com/search |

Default search engine: `ddg` (DuckDuckGo). `search.force = true` overwrites manual engine changes.

## Secret Substitution Pattern

The NextDNS DoH URL is a secret managed by sops-nix. It cannot be embedded directly in the Nix configuration because:

1. The `ProviderURL` value ends up in policy files written to the Nix store, which is world-readable.
2. sops-nix decrypts secrets to runtime paths (`~/.config/sops-secrets/nextdns-url`), not at Nix evaluation time.

The workaround uses a two-phase approach:

**Build time**: The policy is written with a placeholder:
```nix
ProviderURL = "@NEXTDNS_URL@";
```

**Activation time**: A home-manager activation script runs after `writeBoundary` (after all config files are written) and substitutes the placeholder with the actual secret:

```nix
home.activation.substituteZenBrowserSecrets = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  NEXTDNS_URL=$(cat "${config.xdg.configHome}/sops-secrets/nextdns-url")
  find "$HOME/.zen" -type f \( -name "*.js" -o -name "*.json" \) |
    while read file; do
      sed -i "s|@NEXTDNS_URL@|$NEXTDNS_URL|g" "$file"
    done
'';
```

The script is guarded by a file-existence check, so initial builds without decrypted secrets succeed (DoH simply won't activate until secrets are available).

## How To

### Add a new pinned tab

1. Generate a UUID: `uuidgen | tr '[:upper:]' '[:lower:]'`
2. Add an entry inside the appropriate `pinsIn spaces.<Space>` block:
   ```nix
   "Tab Name" = {
     id = "<generated-uuid>";
     url = "https://example.com";
     isEssential = true;  # or omit for non-essential
     position = <number>;  # pick a gap in the sequence
   };
   ```
3. Rebuild.

### Add a new space

1. Generate a UUID for the space.
2. Add a container entry with a unique numeric `id`.
3. Add the space referencing that container's `id`.
4. Use `pinsIn spaces.NewSpace { ... }` to add pins.
5. Rebuild.

### Add a new extension

Add the package name to the `extensions.packages` list. Available extensions are in the `firefox-addons` flake input (rycee's NUR). Browse at https://nur.nix-community.org/ under `rycee.firefox-addons`.

### Add a new search engine

Add an entry to `search.engines`:
```nix
myEngine = {
  name = "My Engine";
  urls = [{ template = "https://example.com/search?q={searchTerms}"; }];
  definedAliases = [ "@me" ];
};
```
