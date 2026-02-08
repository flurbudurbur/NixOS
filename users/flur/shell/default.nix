{ ... }:
{
  imports = [
    ./terminals.nix
    ./starship.nix
    ./tmux.nix
    ./fastfetch.nix
  ];

  # GPG environment variable for terminal pinentry
  home.sessionVariables = {
    GPG_TTY = "$(tty)";
    SOPS_EDITOR = "nvim";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 10000;
      save = 10000;
    };
    shellAliases = {
      btw = "echo I use Nixos, btw";
      nrt = "nixos-rebuild test --sudo --flake /home/flur/nixos-system";
      nrs = "nixos-rebuild switch --sudo --flake /home/flur/nixos-system";
      tmnix = "_tmux_in_dir ~/nixos-system start";
    };
    initContent = ''
      # FNM (Fast Node Manager) initialization
      eval "$(fnm env --use-on-cd)"

      # Helper function to run tmuxinator commands in a specific directory
      _tmux_in_dir() {
        local target_dir="$1"
        local action="$2"

        if [ -z "$target_dir" ]; then
          echo "Error: No directory specified" >&2
          return 1
        fi

        if [ ! -d "$target_dir" ]; then
          echo "Error: Directory '$target_dir' does not exist" >&2
          return 1
        fi

        (cd "$target_dir" && tmuxinator "$action" dev)
      }

      # Start tmuxinator session, optionally in a specific directory
      tmstart() {
        if [ -n "$1" ]; then
          _tmux_in_dir "$1" start
        else
          tmuxinator start dev
        fi
      }

      # Stop tmuxinator session, optionally in a specific directory
      tmstop() {
        if [ -n "$1" ]; then
          _tmux_in_dir "$1" stop
        else
          tmuxinator stop dev
        fi
      }
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "tmux" "podman" ];
    };
  };
}
