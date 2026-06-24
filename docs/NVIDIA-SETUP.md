# NVIDIA Setup on NixOS + Hyprland

Reference for the NVIDIA graphics configuration across this system. The setup spans three files:

- `modules/graphics.nix` -- Driver selection and power management
- `hosts/flurPC/default.nix` -- Kernel parameters and initrd modules
- `users/flur/wayland/hyprland.nix` -- Compositor workarounds

## Driver Configuration

**File**: `modules/graphics.nix`

```nix
hardware.nvidia = {
  modesetting.enable = true;
  open = true;
  powerManagement.enable = true;
  powerManagement.finegrained = false;
};
```

| Option | Value | Why |
|--------|-------|-----|
| `open` | `true` | Uses NVIDIA's open-source kernel modules. Required for newer GPUs (Turing+) and provides better Wayland/KMS support. |
| `modesetting.enable` | `true` | Enables kernel modesetting (KMS). Required for Wayland compositors -- without it, Hyprland cannot drive the display. |
| `powerManagement.enable` | `true` | Registers systemd suspend/resume hooks so the GPU state is saved/restored across sleep cycles. Without this, resume from suspend often produces a black screen or GPU crash. |
| `powerManagement.finegrained` | `false` | Fine-grained power management is for hybrid GPU laptops (PRIME offloading). On a desktop with a single discrete GPU, enabling it causes the GPU to power down when "idle" and break the display. |

32-bit OpenGL (`hardware.graphics.enable32Bit`) is enabled for Steam/Wine compatibility.

## Kernel Parameters

**File**: `hosts/flurPC/default.nix`

```nix
boot.kernelParams = [
  "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  "acpi_enforce_resources=lax"
  ...
];
```

| Parameter | Purpose |
|-----------|---------|
| `nvidia.NVreg_PreserveVideoMemoryAllocations=1` | Tells the NVIDIA driver to save all VRAM contents to system RAM before suspend and restore them on resume. Without this, applications lose their GPU buffers on wake and crash or display corruption. Works in tandem with `powerManagement.enable`. |
| `acpi_enforce_resources=lax` | Relaxes strict ACPI resource checking. Some NVIDIA GPU/motherboard combinations trigger ACPI resource conflicts that prevent the driver from loading. `lax` lets the kernel share those resources rather than failing. |

### Silent Boot Parameters

The remaining kernel params (`quiet`, `splash`, `loglevel=3`, `rd.udev.log_level=3`, `vt.global_cursor_default=0`, `systemd.show_status=0`) suppress console output for a clean Plymouth boot splash -- not NVIDIA-specific, but they rely on the NVIDIA initrd modules being loaded early enough for KMS rendering.

## Initrd Module Loading

**File**: `hosts/flurPC/default.nix`

```nix
boot.initrd.kernelModules = [
  "usbhid"
  "xhci_hcd"
  "nvidia"
  "nvidia_modeset"
  "nvidia_uvm"
  "nvidia_drm"
];
```

These modules are loaded during the initial ramdisk phase (before the root filesystem is mounted). Two reasons:

1. **Plymouth KMS**: The boot splash needs a working display driver early. If NVIDIA modules load late (after initrd), Plymouth falls back to a text-mode console or shows nothing.

2. **Display readiness**: Loading the full module stack (`nvidia` -> `nvidia_modeset` -> `nvidia_uvm` -> `nvidia_drm`) in initrd means the framebuffer is available immediately when the compositor starts, avoiding a visible mode-switch flicker.

The `usbhid` and `xhci_hcd` modules are unrelated to NVIDIA -- they ensure the USB keyboard works during initrd (e.g., for LUKS password entry).

### Module roles

| Module | Role |
|--------|------|
| `nvidia` | Core GPU driver |
| `nvidia_modeset` | Kernel modesetting support (DRM/KMS) |
| `nvidia_uvm` | Unified Virtual Memory -- allows CPU and GPU to share address space (needed by CUDA, some Vulkan features) |
| `nvidia_drm` | DRM (Direct Rendering Manager) interface -- provides the API that Wayland compositors use to talk to the GPU |

## Hyprland Cursor Workarounds

**File**: `users/flur/wayland/hyprland.nix`

```nix
cursor = {
  no_hardware_cursors = true;
  use_cpu_buffer = true;
  default_monitor = "DP-1";
};
```

| Setting | Why |
|---------|-----|
| `no_hardware_cursors` | NVIDIA's hardware cursor plane has longstanding bugs on Wayland -- the cursor disappears, flickers, or renders at the wrong position on multi-monitor setups. Disabling it forces software-rendered cursors, which are slightly more CPU-intensive but reliable. |
| `use_cpu_buffer` | Allocates the cursor buffer in system RAM instead of VRAM. This avoids a class of NVIDIA driver bugs where the hardware cursor buffer gets corrupted or lost during monitor hotplug or DPMS events. Used together with `no_hardware_cursors` for maximum stability. |
| `default_monitor` | Sets which monitor the cursor appears on at startup. Without this, the cursor can spawn on an unexpected monitor in multi-display setups. |

## Environment Variables

The Hyprland config sets cursor theme variables but does **not** set common NVIDIA+Wayland env vars like `GBM_BACKEND`, `__GLX_VENDOR_LIBRARY_NAME`, or `WLR_NO_HARDWARE_CURSORS`. These are either handled automatically by NixOS's NVIDIA module or superseded by Hyprland's built-in settings.

If you encounter issues with specific applications (e.g., Firefox/Electron not using GPU acceleration), you may need to add:

```nix
# In hyprland env or session variables
"GBM_BACKEND" = "nvidia-drm";
"__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
"LIBVA_DRIVER_NAME" = "nvidia";
```

## Debugging

### Common issues

**Black screen after suspend/resume**
- Verify `NVreg_PreserveVideoMemoryAllocations=1` is active: `cat /proc/driver/nvidia/params | grep PreserveVideoMemoryAllocations`
- Check `powerManagement.enable = true` in `graphics.nix`
- Check systemd services: `systemctl status nvidia-suspend.service nvidia-resume.service`

**Plymouth shows text instead of graphical splash**
- Verify NVIDIA modules are in initrd: `lsinitrd | grep nvidia` or check `/etc/initrd-release`
- Ensure `boot.initrd.kernelModules` includes all four NVIDIA modules

**Cursor disappears or flickers**
- Confirm `no_hardware_cursors = true` and `use_cpu_buffer = true` in Hyprland config
- Check with `hyprctl getoption cursor:no_hardware_cursors`

**Application won't use GPU / software rendering fallback**
- Check `nvidia-smi` output to confirm driver is loaded
- Verify with `glxinfo | grep "OpenGL renderer"` (should show your GPU, not llvmpipe)
- For Wayland-native apps, check `EGL_LOG_LEVEL=debug <app>` for EGL errors

**ACPI resource conflicts on boot**
- If `dmesg | grep -i acpi` shows resource conflicts, `acpi_enforce_resources=lax` should resolve them
- If not, check `dmesg | grep -i nvidia` for driver load failures

### Useful commands

```bash
# Driver version and GPU info
nvidia-smi

# Check loaded kernel modules
lsmod | grep nvidia

# Verify modesetting is active
cat /sys/module/nvidia_drm/parameters/modeset  # Should print "Y"

# Check power management state
cat /proc/driver/nvidia/params | grep PreserveVideoMemoryAllocations

# Monitor GPU temperature and clocks
nvidia-smi -q -d TEMPERATURE,CLOCK

# Check Hyprland's GPU backend
hyprctl systeminfo | grep -i gpu
```
