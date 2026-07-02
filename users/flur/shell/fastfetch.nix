{ nixpkgs-unstable, ... }:
{
  programs.fastfetch = {
    enable = true;
    package = nixpkgs-unstable.fastfetch;
    settings = {
      logo = {
        type = "data";
        source = ''
          $1        __    $2____    __
          $1       /  \   $2\   \  /  \
          $1       \   \   $2\   \/   /
          $1     ___\   \___$2\      /
          $1    /            $2\    /   $1/\
          $1   /______________$2\   \  $1/  \
          $2        /   /      $2\   \$1/   /
          $2 ______/   /        $2\  $1/   /___
          $2/         /          $2\$1/        \
          $2\____    /$1\          $1/   ______/
          $2    /   /$1  \        $1/   /
          $2   /   /$1\   \$2______$1/$2___$1/$2_____
          $2   \  /$1  \   \$2              /
          $2    \/$1   /    \$2____    ____/
          $2       $1 /      \$2   \   \
          $2       $1/   /\   \$2   \   \
          $2       $1\__/  \___\$2   \__/
        '';
        color = {
          "1" = "#c4a7e7";
          "2" = "#9ccfd8";
        };
        padding.top = 1;
        width = 16;
      };
      display = {
        separator = "  ";
        key.type = "icon";
        bar = {
          width = 12;
          char.elapsed = "■";
          char.total = "·";
          color = null;
        };
      };
      modules = [
        "break"
        "break"
        "break"
        "os"
        "kernel"
        "uptime"
        {
          type = "packages";
          format = "{nix-system} (system), {nix-user} (home), {flatpak-user} (flatpak)";
        }
        "wm"
        "shell"
        "break"
        "cpu"
        "gpu"
        {
          type = "memory";
          percent.type = [
            "num"
            "bar"
          ];
          format = "{used>10} / {total>10} ({percentage>4} )  {#35}{percentage-bar}{#}";
        }
        {
          type = "disk";
          percent.type = [
            "num"
            "bar"
          ];
          format = "{size-used>10} / {size-total>10} ({size-percentage>4} )  {#36}{size-percentage-bar}{#}";
        }
        "break"
        {
          type = "colors";
          symbol = "circle";
          brightness = "normal";
        }
        {
          type = "colors";
          symbol = "circle";
          brightness = "light";
        }
      ];
    };
  };
}
