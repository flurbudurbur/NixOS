{ pkgs, stdenv, lib, fetchurl, makeWrapper, autoPatchelfHook }:

stdenv.mkDerivation rec {
  pname = "rpgmaker-linux";
  version = "1.1.6";

  # Fetch architecture-specific release
  src = fetchurl {
    url = "https://github.com/bakustarver/rpgmakermlinux-cicpoffs/releases/download/v${version}/rpgmakerlinux-${stdenv.hostPlatform.linuxArch}-v${version}.tar.gz";
    sha256 = {
      x86_64-linux = "sha256-Lwcb0tlAhAgz9dwnZuEhzYHUubHaGQsU5yJBfYMbzQg=";
      i686-linux = lib.fakeSha256;  # Can be added later if needed
      aarch64-linux = lib.fakeSha256;  # Can be added later if needed
      armv7l-linux = lib.fakeSha256;  # Can be added later if needed
    }.${stdenv.hostPlatform.system};
  };

  # Dependencies for patching and runtime
  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    pkgs.bash
    pkgs.wget
    pkgs.coreutils
    pkgs.xdg-utils
    pkgs.file
    pkgs.patchelf
    pkgs.binutils
    pkgs.stdenv.cc.cc.lib
    pkgs.glib
    pkgs.gtk3
    pkgs.alsa-lib
    pkgs.nss
    pkgs.nspr
    pkgs.atk
    pkgs.at-spi2-atk
    pkgs.libdrm
    pkgs.expat
    pkgs.cups
    pkgs.dbus
    pkgs.libxkbcommon
    pkgs.mesa
    pkgs.pango
    pkgs.cairo
    pkgs.xorg.libX11
    pkgs.xorg.libXcomposite
    pkgs.xorg.libXdamage
    pkgs.xorg.libXext
    pkgs.xorg.libXfixes
    pkgs.xorg.libXrandr
    pkgs.xorg.libxcb
    pkgs.xorg.libXi
    pkgs.xorg.libXtst
    pkgs.xorg.libXScrnSaver
    pkgs.libgbm
    pkgs.fontconfig
    pkgs.freetype
    pkgs.systemd
    pkgs.pipewire
    pkgs.pulseaudio
    pkgs.libGL
    pkgs.zlib
    pkgs.libuuid
  ];

  # No build phase - pre-compiled binaries
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Install to Nix store (full installation with all engines)
    mkdir -p $out/bin $out/share/rpgmaker-linux

    # Copy all bundled files from extracted directory
    cp -r * $out/share/rpgmaker-linux/

    # Fix directory structure: script expects nwjs/nwjs/nwjs/ but tarball has nwjs/nwjs/nwjs-vX.X.X-linux-x64/
    # Create the expected nwjs subdirectory and move version directories into it
    mkdir -p $out/share/rpgmaker-linux/nwjs/nwjs/nwjs
    for dir in $out/share/rpgmaker-linux/nwjs/nwjs/nwjs-*; do
      if [ -d "$dir" ]; then
        mv "$dir" $out/share/rpgmaker-linux/nwjs/nwjs/nwjs/
      fi
    done

    # Script also expects cicpoffs at nwjs/nwjs/cicpoffs (not nwjs/cicpoffs)
    # Copy instead of symlink so 'file' command works correctly
    cp $out/share/rpgmaker-linux/nwjs/cicpoffs $out/share/rpgmaker-linux/nwjs/nwjs/cicpoffs
    cp $out/share/rpgmaker-linux/nwjs/dwnwjs.sh $out/share/rpgmaker-linux/nwjs/nwjs/dwnwjs.sh

    # Script also expects packagefiles at nwjs/nwjs/packagefiles (not nwjs/packagefiles)
    cp -r $out/share/rpgmaker-linux/nwjs/packagefiles $out/share/rpgmaker-linux/nwjs/nwjs/packagefiles

    # Script also expects plugins-autoinstall at nwjs/nwjs/plugins-autoinstall
    cp -r $out/share/rpgmaker-linux/nwjs/plugins-autoinstall $out/share/rpgmaker-linux/nwjs/nwjs/plugins-autoinstall

    # Create a helper script to patch NW.js binaries
    cat > $out/bin/.patch-nwjs << 'EOF'
#!/bin/bash
# Patch NW.js binaries for NixOS
NWJS_DIR="$1"
if [ ! -f "$NWJS_DIR/.patched" ]; then
    echo "Patching NW.js in $NWJS_DIR for NixOS..."

    # Patch all ELF binaries and libraries
    find "$NWJS_DIR" -type f | while read -r file; do
        # Check if it's an ELF file
        if readelf -h "$file" >/dev/null 2>&1; then
            FILE_DIR=$(dirname "$file")

            # Set interpreter for executables
            if file "$file" 2>/dev/null | grep -q "executable"; then
                patchelf --set-interpreter "INTERPRETER" "$file" 2>/dev/null || true
            fi

            # Set rpath to include: system libs + file's directory + nwjs root + nwjs lib dir
            RPATH="LIBRARY_PATH:$FILE_DIR:$NWJS_DIR:$NWJS_DIR/lib"
            patchelf --set-rpath "$RPATH" "$file" 2>/dev/null || true
        fi
    done

    touch "$NWJS_DIR/.patched"
    echo "Patching complete!"
fi
EOF
    chmod +x $out/bin/.patch-nwjs

    # Create a writable user data directory structure
    cat > $out/bin/.rpgmaker-linux-unwrapped << 'EOF'
#!/bin/bash
# Set up writable user directory for rpgmaker-linux
export XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_DATA_HOME=''${XDG_DATA_HOME:-$HOME/.local/share}

RPGMAKER_USER_DIR="$XDG_DATA_HOME/rpgmaker-linux"
mkdir -p "$RPGMAKER_USER_DIR/nwjs/nwjs/nwjs"
mkdir -p "$XDG_CONFIG_HOME"

# Copy bundled files to user directory if not already there
if [ ! -d "$RPGMAKER_USER_DIR/nwjs/packagefiles" ]; then
    echo "First run: copying rpgmaker-linux files to $RPGMAKER_USER_DIR..."
    cp -r STORE_PATH/nwjs/* "$RPGMAKER_USER_DIR/nwjs/"
    chmod -R u+w "$RPGMAKER_USER_DIR/nwjs"
fi

# Set config to point to user directory
echo "$RPGMAKER_USER_DIR" > "$XDG_CONFIG_HOME/defrpgmakerlinuxpath.txt"

# Patch any newly downloaded NW.js versions
for nwjs_ver in "$RPGMAKER_USER_DIR/nwjs/nwjs/nwjs"/nwjs-*/; do
    if [ -d "$nwjs_ver" ]; then
        PATCH_SCRIPT "$nwjs_ver"
    fi
done

# Change to user directory so downloads work correctly
cd "$RPGMAKER_USER_DIR"

# Run the launcher from user directory
# Note: PATH and LD_LIBRARY_PATH are inherited from the wrapper
exec bash "$RPGMAKER_USER_DIR/nwjs/packagefiles/nwjsstart-cicpoffs.sh" "$@"
EOF
    # Get the dynamic linker path and library path for patching downloaded binaries
    INTERPRETER=$(cat $NIX_CC/nix-support/dynamic-linker)
    RPATH="${lib.makeLibraryPath buildInputs}"

    # Substitute paths in patch script
    sed -i "s|INTERPRETER|$INTERPRETER|g" $out/bin/.patch-nwjs
    sed -i "s|LIBRARY_PATH|$RPATH|g" $out/bin/.patch-nwjs
    sed -i "s|AUTOPATCHELF_PATH|${pkgs.autoPatchelfHook}|g" $out/bin/.patch-nwjs

    # Substitute paths in wrapper script
    sed -i "s|STORE_PATH|$out/share/rpgmaker-linux|g" $out/bin/.rpgmaker-linux-unwrapped
    sed -i "s|PATCH_SCRIPT|$out/bin/.patch-nwjs|g" $out/bin/.rpgmaker-linux-unwrapped
    chmod +x $out/bin/.rpgmaker-linux-unwrapped

    # The main launcher is a wrapper around our setup script
    # Force X11/XWayland backend since Wayland crashes with NW.js
    makeWrapper $out/bin/.rpgmaker-linux-unwrapped $out/bin/rpgmaker-linux \
      --prefix PATH : ${lib.makeBinPath buildInputs} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs} \
      --set NIXOS_OZONE_WL "" \
      --unset WAYLAND_DISPLAY \
      --unset XDG_SESSION_TYPE \
      --set GDK_BACKEND "x11" \
      --set QT_QPA_PLATFORM "xcb"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Native Linux launcher for RPG Maker games (MV/MZ/XP/VX/VX Ace and more)";
    longDescription = ''
      Bash-based wrapper that enables native Linux execution of RPG Maker games
      with 2-4x better performance than Wine. Supports RPG Maker MV, MZ, XP, VX,
      VX Ace, TyranoBuilder, Godot, Construct 2/3, and more.
    '';
    homepage = "https://github.com/bakustarver/rpgmakermlinux-cicpoffs";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux" ];
    maintainers = [ ];
  };
}
