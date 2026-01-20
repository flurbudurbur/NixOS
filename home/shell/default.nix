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
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "tmux" "podman" ];
    };
    initContent = ''
      # Auto-attach to tmuxinator "dev" session (created at login by systemd)
      if [[ -z "$TMUX" ]] && [[ $- == *i* ]]; then
        if tmux has-session -t dev 2>/dev/null; then
          tmux attach-session -t dev
        fi
      fi
    '';
  };
}
