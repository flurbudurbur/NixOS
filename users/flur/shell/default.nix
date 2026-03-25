{ ... }:
{
  imports = [
    ./terminals.nix
    ./starship.nix
    ./tmux.nix
    ./fastfetch.nix
  ];

  # Add ~/.local/bin to PATH
  home.sessionPath = [ "$HOME/.local/bin" ];

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
      fastfetch

      # FNM (Fast Node Manager) initialization
      eval "$(fnm env --use-on-cd)"

      # Zoxide initialization (replaces cd with smart directory jumping)
      eval "$(zoxide init zsh --cmd cd)"

      # Sesh session picker widget (Ctrl+k)
      function sesh-sessions() {
        local session
        session=$(sesh list -i | fzf --height 40% --reverse --border-label ' sesh ' --prompt '⚡  ' \
          --header ' ^a all ^t tmux ^g configs ^x zoxide ^d kill' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list -i)' \
          --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -it)' \
          --bind 'ctrl-g:change-prompt(⚙️   )+reload(sesh list -ic)' \
          --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -iz)' \
          --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list -i)' \
          | awk '{print $2}')
        [[ -z "$session" ]] && return
        sesh connect "$session"
      }
      zle -N sesh-sessions
      bindkey '^k' sesh-sessions

      # Mullvad VPN status with polling until connected
      mvs() {
        while true; do
          local vpn_status
          vpn_status=$(mullvad status)
          echo "$vpn_status"
          if echo "$vpn_status" | grep -q "^Connected"; then
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
