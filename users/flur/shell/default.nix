{ ... }:
{
  imports = [
    ./terminals.nix
    ./starship.nix
    ./tmux.nix
    ./nerdfetch.nix
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
      ncheck = "nix flake check --no-build /home/flur/nixos-system";
      nfmt = "nix fmt /home/flur/nixos-system";
      mvr = "mullvad reconnect";
    };
    initContent = ''
      # Display system info on shell start
      nerdfetch

      # FNM (Fast Node Manager) initialization
      eval "$(fnm env --use-on-cd)"

      # Zoxide initialization (replaces cd with smart directory jumping)
      eval "$(zoxide init zsh --cmd cd)"

      # Sesh session picker widget (Ctrl+t)
      function sesh-sessions() {
        local session
        session=$(sesh list -i | fzf --height 40% --reverse --border-label ' sesh ' --prompt '⚡  ' \
          --header ' ^a all ^t tmux ^g configs ^x zoxide ^d kill' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list -i)' \
          --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -it)' \
          --bind 'ctrl-g:change-prompt(⚙️   )+reload(sesh list -ic)' \
          --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -iz)' \
          --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list -i)')
        [[ -z "$session" ]] && return
        sesh connect "$session"
      }
      zle -N sesh-sessions
      bindkey '^k' sesh-sessions

      # Helper function to run tmuxinator commands in a specific directory
      _tmux_in_dir() {
        local target_dir="$1"
        local action="$2"
        local session="''${3:-dev}"

        if [ -z "$target_dir" ]; then
          echo "Error: No directory specified" >&2
          return 1
        fi

        if [ ! -d "$target_dir" ]; then
          echo "Error: Directory '$target_dir' does not exist" >&2
          return 1
        fi

        (cd "$(zoxide query "$target_dir")" && tmuxinator "$action" "$session")
      }

      # Start tmuxinator session: tmstart [dir] [session]  (defaults: . dev)
      tmstart() {
        _tmux_in_dir "''${1:-.}" start "''${2:-dev}"
      }

      # Stop tmuxinator session: tmstop [dir] [session]  (defaults: . dev)
      tmstop() {
        _tmux_in_dir "''${1:-.}" stop "''${2:-dev}"
      }

      # Mullvad VPN status with polling until connected
      mvs() {
        while true; do
          local status
          status=$(mullvad status)
          echo "$status"
          if echo "$status" | grep -q "^Connected"; then
            break
          fi
          sleep 1
        done
      }
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "tmux"
        "podman"
      ];
    };
  };
}
