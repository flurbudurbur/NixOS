{ pkgs, icons }:

let
  net = icons.network;
  script = pkgs.writeShellScript "net-icon" ''
    t=$(nmcli -t -f TYPE,STATE connection show --active 2>/dev/null | grep activated | head -1 | cut -d: -f1)
    if echo "$t" | grep -q "wireless\|wifi"; then
      s=$(nmcli -t -f IN-USE,SIGNAL device wifi 2>/dev/null | grep '^\*' | head -1 | cut -d: -f2)
      s=''${s:-0}
      if   [ "$s" -ge 75 ]; then echo "${net.full}"
      elif [ "$s" -ge 50 ]; then echo "${net.high}"
      elif [ "$s" -ge 25 ]; then echo "${net.medium}"
      else echo "${net.low}"
      fi
    elif echo "$t" | grep -q "ethernet"; then
      echo "${net.ethernet}"
    else
      echo "${net.off}"
    fi
  '';
in
{
  inherit script;

  yuck = ''
    (defpoll net-icon
      :interval "5s"
      "${script}")

    (defwidget network []
      (box
        :class "network module"
        :orientation "h"
        (label :text {net-icon})))
  '';

  scss = ''
    .network {
      color: $cyan;
    }
  '';
}
