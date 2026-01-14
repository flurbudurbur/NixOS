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
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "tmux" "podman" ];
    };
    initContent = ''
      # Display system info with fastfetch
      fastfetch

      # Auto-start tmuxinator "dev" session when opening a terminal
      if [[ -z "$TMUX" ]]; then
        if command -v tmuxinator &> /dev/null; then
          tmuxinator start dev 2>/dev/null || true
        fi
      fi
    '';
  };
}
