{ pkgs, icons }:

let
  statusScript = pkgs.writeShellScript "vpn-status" ''
    state=$(${pkgs.ivpn}/bin/ivpn status 2>/dev/null | grep '^VPN' | awk -F':' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')
    if [ "$state" = "CONNECTED" ]; then
      echo "${icons.vpn.locked}"
    else
      echo "${icons.vpn.unlocked}"
    fi
  '';

  openScript = pkgs.writeShellScript "vpn-open" ''
    ${pkgs.ivpn-ui}/bin/ivpn-ui &
  '';
in
{
  inherit statusScript openScript;

  yuck = ''
    (defpoll vpn-icon
      :interval "5s"
      "${statusScript}")

    (defwidget vpn []
      (button
        :class "vpn module"
        :onclick "${openScript}"
        :halign "fill"
        :hexpand true
        :valign "center"
        :width 51
        :height 51
        (label :text {vpn-icon})))
  '';

  scss = ''
    button.vpn {
      color: $accent2;
      padding: 0;
    }
  '';
}
