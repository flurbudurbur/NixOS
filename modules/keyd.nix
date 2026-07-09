_: {
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "3233:5311" ];
      settings.main = {
        capslock = "layer(control)";
        leftcontrol = "capslock";
      };
    };
    keyboards.tartarus = {
      ids = [ "1532:0244" ];
      settings = {
        main = {
          # Hold profile button -> profile select (A=functions S=gaming D=numpad)
          leftalt = "layer(profile_select)";

          # G1-G5 (1 2 3 4 5) -> F1-F5
          "1" = "f1";
          "2" = "f2";
          "3" = "f3";
          "4" = "f4";
          "5" = "f5";

          # G6-G10 (tab q w e r) -> F6-F10
          tab = "f6";
          q = "f7";
          w = "f8";
          e = "f9";
          r = "f10";

          # G11-G15 (capslock a s d f) -> F11-F15
          capslock = "f11";
          a = "f12";
          s = "f13";
          d = "f14";
          f = "f15";

          # G16-G19 (leftshift z x c) -> F16-F19
          leftshift = "f16";
          z = "f17";
          x = "f18";
          c = "f19";
        };

        gaming = {
          # Hold profile button -> profile select (A=functions S=gaming D=numpad)
          leftalt = "layer(profile_select)";

          # G1 -> ESC, G2-G5 -> 1-4
          "1" = "esc";
          "2" = "1";
          "3" = "2";
          "4" = "3";
          "5" = "4";

          # G6-G10: pass-through (overrides main's F-key remaps)
          tab = "tab";
          q = "q";
          w = "w";
          e = "e";
          r = "r";

          # G11 (capslock) -> ctrl modifier; G12-G15: pass-through
          capslock = "layer(control)";
          a = "a";
          s = "s";
          d = "d";
          f = "f";

          # G16-G19: pass-through
          leftshift = "leftshift";
          z = "z";
          x = "x";
          c = "c";
        };

        numpad = {
          # Hold profile button -> profile select (A=functions S=gaming D=numpad)
          leftalt = "layer(profile_select)";

          # Phone-style numpad layout
          q = "1";
          w = "2";
          e = "3";

          a = "4";
          s = "5";
          d = "6";

          z = "7";
          x = "8";
          c = "9";

          leftshift = "0";
          capslock = ".";
        };

        # Hold profile button, tap to select:
        #   A = functions (clears all toggled layers)
        #   S = gaming
        #   D = numpad
        profile_select = {
          a = "clear()";
          s = "toggle(gaming)";
          d = "toggle(numpad)";
        };
      };
    };
  };
}
