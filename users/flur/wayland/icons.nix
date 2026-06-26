let
  # Decode a Unicode character from a JSON \uXXXX escape string.
  # BMP codepoints (U+0000–U+FFFF) take a single \uXXXX.
  # Supplementary codepoints (U+10000+) require a surrogate pair: \uHHHH\uLLLL.
  fromUnicode = s: builtins.elemAt (builtins.fromJSON "[\"${s}\"]") 0;
in
{
  # Workspace indicators (standard Unicode geometric shapes — BMP PUA codepoints like
  # U+F111 are stripped by builtins.fromJSON; use plain Unicode instead)
  wsActive = fromUnicode "\\u25CF"; # U+25CF  ● BLACK CIRCLE
  wsOccupied = fromUnicode "\\u25C9"; # U+25C9  ◉ FISHEYE
  wsEmpty = fromUnicode "\\u25CB"; # U+25CB  ○ WHITE CIRCLE

  # Network icons (Nerd Font Material Design Icons, Supplementary Private Use Area)
  wifiFull = fromUnicode "\\udb82\\udd28"; # U+F0928  nf-md-wifi-strength-4
  wifiHigh = fromUnicode "\\udb82\\udd25"; # U+F0925  nf-md-wifi-strength-3
  wifiMed = fromUnicode "\\udb82\\udd22"; # U+F0922  nf-md-wifi-strength-2
  wifiLow = fromUnicode "\\udb82\\udd1f"; # U+F091F  nf-md-wifi-strength-1
  ethernet = fromUnicode "\\udb80\\udc00"; # U+F0200  nf-md-ethernet
  wifiOff = fromUnicode "\\udb82\\udd2d"; # U+F092D  nf-md-wifi-strength-off-outline

  # System icons (Nerd Font Material Design Icons, Supplementary Private Use Area)
  cpu = fromUnicode "\\udb83\\udee0"; # U+F0EE0  nf-md-cpu-64-bit
  memory = fromUnicode "\\udb80\\udf5b"; # U+F035B  nf-md-memory
}
