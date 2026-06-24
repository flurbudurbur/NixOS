# Theme System

Runtime theme switching with multiple color schemes. Themes are defined as Nix attrsets, compiled to per-app config files at build time, and swapped at runtime via a symlink.

## Data Flow

```
Color definitions                   Build time                      Runtime
─────────────────                   ──────────                      ───────
modules/themes/*.nix    ─┐
                         ├─► themes attrset ─► mkThemeFiles() ─► ~/.config/themes/<name>/
tinted-theming YAML     ─┘                      generates:         ├── hyprland.lua
  (via tinted.nix list)                          12 files per       ├── waybar-style.css
                                                 theme              ├── foot-colors.ini
                                                                    ├── starship.toml
                                                                    ├── walker-style.css
                                                                    ├── hyprlock.conf
                                                                    ├── mako.conf
                                                                    ├── nvim-theme.lua
                                                                    ├── zen-userchrome.css
                                                                    ├── gtk.css
                                                                    ├── scheme.yaml
                                                                    └── wallpaper (if exists)

                                                                 ~/.config/themes/current → symlink
                                                                    (points to active theme dir)
```

Apps source their config from `~/.config/themes/current/<file>`, so changing the symlink changes the theme.

## Color Schema

Every theme must provide these 15 color attributes (validated at build time):

| Attribute   | Role                   | base16 mapping |
|-------------|------------------------|----------------|
| `bg`        | Primary background     | base00         |
| `bg_alt`    | Secondary background   | base01         |
| `bg_select` | Selection background   | base02         |
| `fg_faint`  | Muted foreground       | base03         |
| `fg_dim`    | Dim foreground         | base04         |
| `fg`        | Primary foreground     | base05         |
| `error`     | Error/destructive      | base08         |
| `warning`   | Warning/caution        | base09         |
| `accent2`   | Secondary accent       | base0A         |
| `blue`      | Primary accent (links) | base0D         |
| `cyan`      | Positive/success       | base0C         |
| `accent`    | Tertiary accent        | base0E         |
| `hl_low`    | Subtle highlight       | base01         |
| `hl_med`    | Medium highlight       | base02         |
| `hl_high`   | Strong highlight       | base03         |

All values are `#RRGGBB` hex strings.

## Theme Sources

Themes come from two places, merged together in `modules/themes/default.nix`:

### Custom themes (auto-discovered .nix files)

Any `.nix` file in `modules/themes/` (except `default.nix`, `tinted.nix`, `parse-scheme.nix`) is auto-discovered and imported as a theme. The filename minus `.nix` becomes the theme name.

Example: `modules/themes/sweet.nix` defines the "sweet" theme as a plain attrset:

```nix
{
  bg = "#161925";
  bg_alt = "#222e39";
  # ...all 15 required attributes
}
```

### Tinted-theming schemes (from upstream YAML)

`modules/themes/tinted.nix` lists theme names to import from the `tinted-schemes` flake input:

```nix
[ "rose-pine-moon" "catppuccin-mocha" "sakura" ]
```

For each name, `default.nix` looks for `base24/<name>.yaml` first, then `base16/<name>.yaml` in the tinted-schemes repository. `parse-scheme.nix` reads the YAML, extracts the `baseXX` palette entries, and maps them to the 15-attribute schema above.

## How Apps Consume Themes

Each app includes `~/.config/themes/current/<file>` using its native import/source mechanism:

| App        | Theme file           | How it's included                                                    | Reload method               |
|------------|----------------------|----------------------------------------------------------------------|-----------------------------|
| Hyprland   | `hyprland.lua`       | `dofile()` in Lua config (`hyprland.nix:523`)                        | `hyprctl reload`            |
| Waybar     | `waybar-style.css`   | `@import url()` in CSS (`waybar.nix:120`)                            | `SIGUSR2`                   |
| Foot       | `foot-colors.ini`    | `include` directive (`terminals.nix:10`)                             | `SIGUSR1`                   |
| Walker     | `walker-style.css`   | `@import url()` in CSS (`walker.nix:62`)                             | `systemctl restart walker`  |
| Hyprlock   | `hyprlock.conf`      | `source` directive (`hyprlock.nix:26`)                               | Applied on next lock         |
| Mako       | `mako.conf`          | `include` directive (`mako.nix:10`)                                  | `makoctl reload`            |
| Neovim     | `nvim-theme.lua`     | `dofile()` on startup (`nvim.nix:262`)                               | `:source` via `--remote-send` |
| Starship   | `starship.toml`      | `STARSHIP_CONFIG` env var (`shell/default.nix:24`)                   | New prompt renders pick it up |
| Zen Browser| `zen-userchrome.css` | Symlinked to `~/.config/zen/default/chrome/userChrome.css`           | Browser restart              |
| GTK        | `gtk.css`            | `@import url()` via stylix `extraCss` (`xdg.nix:10`)                | gsettings color-scheme toggle |
| Terminals  | (OSC sequences)      | Written directly to `/dev/pts/*` by the switch script                | Immediate                    |

### Starship specifics

The starship theme file is the base config from `dotfiles/starship.toml` with a `[palettes.theme]` section appended. The base config references palette colors like `overlay`, `love`, `pine`, `foam`, `iris`, `rose`, `gold` — these are mapped to theme attributes at build time. The `STARSHIP_CONFIG` env var is force-set to point at the current theme's `starship.toml`.

## `theme-switch` Script

Generated at build time in `users/flur/wayland/themes.nix`. Usage:

```bash
theme-switch rose-pine-moon   # switch to named theme
theme-switch                  # cycle to next theme
```

What it does:
1. Updates `~/.config/themes/current` symlink to the new theme directory
2. Sets wallpaper via `awww` (if `wallpaper` file exists in theme dir, with 1.5s transition)
3. Reloads all participating apps (see reload methods in table above)
4. Sends OSC escape sequences to all open terminal PTYs to update terminal colors immediately
5. Finds running Neovim instances via their Unix sockets and `:source`s the new theme
6. Toggles `gsettings color-scheme` to force GTK apps to re-read their CSS
7. Sends a desktop notification confirming the switch

## tuigreet (System-Level Theming)

`modules/desktop.nix` imports the themes module directly and hardcodes `rose-pine-moon` colors into the tuigreet command line. This runs as a system service before user login, so it does not participate in runtime switching. To change the login screen colors, edit `modules/desktop.nix`.

## Adding a New Theme

### From a tinted-theming scheme

1. Find the scheme name in the [tinted-theming/schemes](https://github.com/tinted-theming/schemes) repository (e.g., `dracula`)
2. Add the name to `modules/themes/tinted.nix`:
   ```nix
   [ "rose-pine-moon" "catppuccin-mocha" "sakura" "dracula" ]
   ```
3. Optionally add a wallpaper at `wallpapers/dracula.{jpg,png,webp,gif}`
4. Rebuild — all 12 per-app files are auto-generated

### Custom theme

1. Create `modules/themes/yourtheme.nix` with all 15 required color attributes
2. Optionally add a wallpaper at `wallpapers/yourtheme.{jpg,png,webp,gif}`
3. Rebuild — the file is auto-discovered and all per-app files are generated

No changes to `themes.nix` or any app config are needed in either case.

## Adding Theme Support for a New App

1. In `users/flur/wayland/themes.nix`:
   - Write a `mkYourAppTheme` function that takes a theme attrset `t` and returns the config file content as a string
   - Add `"themes/${name}/yourapp-config.ext".text = mkYourAppTheme t;` inside `mkThemeFiles`
2. In your app's Nix module, include `~/.config/themes/current/yourapp-config.ext` using whatever mechanism the app supports (`@import`, `include`, `source`, `dofile`, env var, etc.)
3. In the `theme-switch` script (in `themes.nix`), add the reload command for your app (signal, restart, etc.)

## Debugging

**Theme not applying to an app:**
- Check the symlink: `ls -la ~/.config/themes/current` — should point to a valid theme directory
- Check the theme file exists: `ls ~/.config/themes/current/<app-config-file>`
- Check the app's config actually includes from `themes/current/` (see table above for file paths)

**Theme applies but colors are wrong:**
- Inspect the generated file: `cat ~/.config/themes/current/<file>` — verify colors match your theme definition
- For tinted-theming themes, the base16-to-semantic mapping in `parse-scheme.nix` may not produce ideal results for every scheme; check if the mapping makes sense for that palette

**Wallpaper not changing:**
- Verify `awww-daemon` is running: `systemctl --user status awww`
- Check wallpaper file exists: `ls ~/.config/themes/<name>/wallpaper`

**Neovim not updating:**
- The script finds Neovim instances via Unix sockets in `$XDG_RUNTIME_DIR`. Verify with: `ls $XDG_RUNTIME_DIR/nvim*`
- Neovim uses `mini.base16` for the color scheme; if it's not installed, the theme lua will error

**Zen Browser requires restart:**
- Unlike other apps, Zen Browser doesn't support live CSS reload. The switch script kills and relaunches it.

**New terminal sessions use old colors:**
- The OSC sequences update existing PTYs. New terminals pick up colors from `foot-colors.ini` via the `include` directive, which follows the symlink, so they should get the current theme automatically.
