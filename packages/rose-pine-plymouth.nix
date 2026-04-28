{ runCommand, imagemagick }:

runCommand "rose-pine-plymouth" {
  nativeBuildInputs = [ imagemagick ];
  meta.description = "Rose Pine Moon Plymouth spinner theme";
} ''
  themedir="$out/share/plymouth/themes/rose-pine-moon"
  mkdir -p "$themedir"

  # Iris-colored dot: 16x16 canvas, radius-7 circle, 1px transparent border
  convert -size 16x16 xc:none \
    -fill "#c4a7e7" -stroke none \
    -draw "circle 8,8 8,1" \
    "$themedir/dot.png"

  cat > "$themedir/rose-pine-moon.plymouth" << EOF
[Plymouth Theme]
Name=Rose Pine Moon
Description=Rose Pine Moon spinner theme
ModuleName=script

[script]
ImageDir=$out/share/plymouth/themes/rose-pine-moon
ScriptFile=$out/share/plymouth/themes/rose-pine-moon/rose-pine-moon.script
EOF

  cat > "$themedir/rose-pine-moon.script" << 'SCRIPT'
# Rose Pine Moon: base #232136 background, iris #c4a7e7 dots
Window.SetBackgroundTopColor(35 / 255.0, 33 / 255.0, 54 / 255.0);
Window.SetBackgroundBottomColor(35 / 255.0, 33 / 255.0, 54 / 255.0);

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
