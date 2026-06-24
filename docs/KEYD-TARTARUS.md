# Keyd Configuration: Default Keyboard and Razer Tartarus

Configured in `modules/keyd.nix`. The keyd service runs two independent keyboard configs matched by USB vendor/product ID.

## Default Keyboard (ID: 3233:5311)

Simple swap on the main layer:

| Physical Key  | Output       |
|---------------|--------------|
| Caps Lock     | Control (held) |
| Left Control  | Caps Lock    |

No other remapping. All other keys pass through.

---

## Razer Tartarus V2 (ID: 1532:0244)

The Tartarus is a 20-key left-hand keypad with a thumbpad area. Keyd sees it as a standard keyboard with specific scancodes — the physical G-keys map to the logical keys shown below.

### Physical Layout and Logical Key Mapping

The Tartarus has 4 rows of keys (G1-G19) plus a thumb area. Keyd receives these as the following logical keys:

```
Row 1 (G1-G5):     [ 1 ]  [ 2 ]  [ 3 ]  [ 4 ]  [ 5 ]

Row 2 (G6-G10):    [tab]  [ q ]  [ w ]  [ e ]  [ r ]

Row 3 (G11-G15):   [caps] [ a ]  [ s ]  [ d ]  [ f ]

Row 4 (G16-G19):      [lshift]  [ z ]  [ x ]  [ c ]
                       (wider key)

Thumb cluster:      [lalt]   (profile select when held)
                    (thumbpad/joystick buttons not remapped)
```

The thumb `leftalt` key is used as the profile-switching modifier across all layers.

### Profile System

The Tartarus has 3 profiles, switched at runtime via the thumb button. Hold `leftalt` (thumb key), then tap one of:

| Tap Key | Logical Key | Action            | Profile Activated |
|---------|-------------|-------------------|-------------------|
| G12     | `a`         | `clear()`         | Functions (main)  |
| G13     | `s`         | `toggle(gaming)`  | Gaming            |
| G14     | `d`         | `toggle(numpad)`  | Numpad            |

How the keyd layer mechanics work:

- **`toggle(layer)`** activates a layer persistently — it stays active until toggled off or cleared.
- **`clear()`** removes all toggled layers, returning to the `main` layer.
- Selecting "functions" (key `a`) calls `clear()`, which drops back to `main`.
- Selecting "gaming" toggles on the `gaming` layer, which overrides `main`.
- Selecting "numpad" toggles on the `numpad` layer, which overrides `main`.
- If you toggle gaming then toggle numpad without clearing first, both layers stack (numpad wins on conflicts). In practice, always clear first or toggle the same layer off before switching.
- The `profile_select` layer itself is a hold-layer (`layer(profile_select)`) on `leftalt`, so it is only active while the thumb key is held. Releasing the thumb key returns to whichever persistent layer is active.

### Profile 1: Functions (main layer, default)

All G-keys mapped to function keys. Intended for productivity shortcuts, window management, or application hotkeys.

```
[ F1 ]  [ F2 ]  [ F3 ]  [ F4 ]  [ F5 ]

[ F6 ]  [ F7 ]  [ F8 ]  [ F9 ]  [F10 ]

[F11 ]  [F12 ]  [F13 ]  [F14 ]  [F15 ]

    [F16 ]  [F17 ]  [F18 ]  [F19 ]
```

### Profile 2: Gaming

Standard WASD layout with G1 as Escape. Designed for FPS/general gaming.

```
[Esc ]  [ 1  ]  [ 2  ]  [ 3  ]  [ 4  ]

[Tab ]  [ Q  ]  [ W  ]  [ E  ]  [ R  ]

[Ctrl]  [ A  ]  [ S  ]  [ D  ]  [ F  ]

    [LShift]  [ Z  ]  [ X  ]  [ C  ]
```

Notes:
- G1 becomes Escape instead of 1 (number row shifts down by one).
- G11 (capslock) becomes Control (held), matching the default keyboard's caps-to-ctrl swap.
- Everything else passes through as the standard key.

### Profile 3: Numpad

Phone-style number pad on the middle 3x3 grid (G7-G9, G12-G14, G17-G19). Row 1 (G1-G5) is not remapped in this layer, so it falls through to `main` (F1-F5).

```
 (falls through to main layer row 1)

        [ 1  ]  [ 2  ]  [ 3  ]

[ .  ]  [ 4  ]  [ 5  ]  [ 6  ]

    [ 0  ]  [ 7  ]  [ 8  ]  [ 9  ]
```

Notes:
- G11 (capslock) becomes `.` (decimal point).
- G16 (leftshift) becomes `0`.
- G6 (tab) and G10 (r) are not remapped in this layer — they fall through to `main` (F6, F10).
- Row 1 and unmapped keys inherit from the functions profile since `main` is always the base layer.

## Design Decisions

**Why F13-F19?** These are valid keycodes that no standard application binds by default. This makes them safe targets for custom shortcuts in Hyprland, OBS, or any other tool — they won't conflict with existing keybindings.

**Why phone-style numpad (1-2-3 on top)?** Matches phone/calculator layout rather than the traditional numpad (7-8-9 on top). Personal preference for data entry.

**Why `clear()` for the functions profile?** The `main` layer is always present as the base. Rather than creating a redundant `functions` toggle layer, `clear()` strips all toggled layers to expose `main` directly. This avoids layer stacking issues.

**Why `layer()` on leftalt for profile select?** A hold-layer ensures the profile selector is only active while the thumb is held, so it never interferes with normal key operation. The physical thumb button is naturally accessible and distinct from the main key grid.
