{
  runCommand,
  imagemagick,
  lib,
}:
{
  name,
  bg,
  dot,
  wallpaper ? null,
}:
let
  strip = hex: builtins.substring 1 6 hex;
in
runCommand "plymouth-theme-${name}"
  {
    nativeBuildInputs = [ imagemagick ];
    meta.description = "${name} Plymouth spinner theme";
  }
  ''
      themedir="$out/share/plymouth/themes/${name}"
      mkdir -p "$themedir"

      # Dot-colored spinner: 16x16 canvas, radius-7 circle, 1px transparent border
      convert -size 16x16 xc:none \
        -fill "${dot}" -stroke none \
        -draw "circle 8,8 8,1" \
        "$themedir/dot.png"

      ${lib.optionalString (wallpaper != null) ''
        # Boot backgrounds are shown at low/native res only briefly; cap size to
        # keep the initrd (which embeds every theme) from ballooning.
        convert "${wallpaper}" -resize '1920x1080>' -strip "$themedir/background.png"
      ''}

      cat > "$themedir/${name}.plymouth" << EOF
    [Plymouth Theme]
    Name=${name}
    Description=${name} spinner theme
    ModuleName=script

    [script]
    ImageDir=$out/share/plymouth/themes/${name}
    ScriptFile=$out/share/plymouth/themes/${name}/${name}.script
    EOF

      bg_hex="${strip bg}"
      bg_r=$((16#''${bg_hex:0:2}))
      bg_g=$((16#''${bg_hex:2:2}))
      bg_b=$((16#''${bg_hex:4:2}))

      cat > "$themedir/${name}.script" << SCRIPT
    Window.SetBackgroundTopColor($bg_r / 255.0, $bg_g / 255.0, $bg_b / 255.0);
    Window.SetBackgroundBottomColor($bg_r / 255.0, $bg_g / 255.0, $bg_b / 255.0);

    ${lib.optionalString (wallpaper != null) ''
      screen_w = Window.GetWidth();
      screen_h = Window.GetHeight();
      bg_image = Image("background.png");
      img_w = bg_image.GetWidth();
      img_h = bg_image.GetHeight();
      scale_w = screen_w / (img_w * 1.0);
      scale_h = screen_h / (img_h * 1.0);
      if (scale_w > scale_h) {
          bg_scale = scale_w;
      } else {
          bg_scale = scale_h;
      }
      bg_sprite = Sprite(bg_image.Scale(img_w * bg_scale, img_h * bg_scale));
      bg_sprite.SetX((screen_w - img_w * bg_scale) / 2);
      bg_sprite.SetY((screen_h - img_h * bg_scale) / 2);
      bg_sprite.SetZ(-100);
    ''}

    num_dots = 12;
    spinner_r = 32;
    dot_img = Image("dot.png");
    half_w = dot_img.GetWidth() / 2.0;
    half_h = dot_img.GetHeight() / 2.0;

    cx = Window.GetWidth() / 2;
    cy = Window.GetHeight() / 2;

    for (i = 0; i < num_dots; i++) {
        angle = i * (2.0 * Math.Pi / 12.0);
        dots[i] = Sprite(dot_img);
        dots[i].SetX(cx + Math.Cos(angle) * spinner_r - half_w);
        dots[i].SetY(cy + Math.Sin(angle) * spinner_r - half_h);
        dots[i].SetZ(10000);
    }

    frame = 0;

    fun refresh_callback() {
        frame = frame + 1;
        head = (frame / 2) % num_dots;
        for (i = 0; i < num_dots; i++) {
            dist = (head - i + num_dots) % num_dots;
            opacity = 1.0 - (dist / 12.0) * 0.9;
            dots[i].SetOpacity(opacity);
        }
    }

    Plymouth.SetRefreshFunction(refresh_callback);
    SCRIPT
  ''
