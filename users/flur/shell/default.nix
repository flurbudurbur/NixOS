{
  lib,
  ...
}:
{
  imports = [
    ./fastfetch.nix
    ./terminals.nix
    ./tmux.nix
  ];

  # Add ~/.local/bin to PATH
  home.sessionPath = [ "$HOME/.local/bin" ];

  # GPG environment variable for terminal pinentry
  home.sessionVariables = {
    GPG_TTY = "$(tty)";
    SOPS_EDITOR = "nvim";
    STARSHIP_CONFIG = lib.mkForce "$HOME/.config/themes/current/starship.toml";
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = true;
    icons = "auto";
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fd.enable = true;

  programs.ripgrep.enable = true;

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [
      "--cmd"
      "cd"
    ];
  };

  programs.sesh = {
    enable = true;
    enableAlias = false;
    enableTmuxIntegration = false;
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      btw = "echo I use Nixos, btw";
      nrt = "nixos-rebuild test --sudo --flake /home/flur/nixos-system";
      nrs = "nixos-rebuild switch --sudo --flake /home/flur/nixos-system";
      nfc = "nix flake check --no-build /home/flur/nixos-system";
      nf = "nix fmt /home/flur/nixos-system";
      ivr = "ivpn connect -f";
      ls = "eza";
    };

    interactiveShellInit = ''
      set -g fish_greeting

      # Display system info on shell start
      fastfetch

      # FNM (Fast Node Manager) initialization
      fnm env --use-on-cd --shell fish | source

      # Sesh session picker widget (Ctrl+k)
      bind \ck sesh-sessions

      # ESC-ESC prepends sudo to the current commandline (oh-my-zsh sudo plugin equivalent)
      bind \e\e __prepend_sudo
    '';

    functions = {
      sesh-sessions = ''
        set -l session (sesh list -i | fzf --height 40% --reverse --border-label ' sesh ' --prompt '  ' \
          --color 'label:#c4a7e7:bold,prompt:#f6c177:bold' \
          --header ' ^a all ^t tmux ^g configs ^x zoxide ^d kill' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt( )+reload(sesh list -i)' \
          --bind 'ctrl-t:change-prompt( )+reload(sesh list -it)' \
          --bind 'ctrl-g:change-prompt( )+reload(sesh list -ic)' \
          --bind 'ctrl-x:change-prompt( )+reload(sesh list -iz)' \
          --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt( )+reload(sesh list -i)' \
          | awk '{print $2}')
        if test -z "$session"
            return
        end
        sesh connect $session
        commandline -f repaint
      '';

      __prepend_sudo = ''
        commandline -i "sudo "
      '';

      # Claude wrapper for custom subcommands
      claude = ''
        switch $argv[1]
            case todo
                command claude "Read @todo.txt and recommend the next task to work on."
            case '*'
                command claude $argv
        end
      '';

      # Sesh wrapper: omit "connect" subcommand (sesh <name> -> sesh connect <name>)
      sesh = ''
        if test (count $argv) -eq 0
            command sesh
            return
        end
        switch $argv[1]
            case connect last list new root clone
                command sesh $argv
            case '*'
                command sesh connect $argv
        end
      '';

      # Close all windows on a workspace without switching to it
      closews = ''
        set -l ws $argv[1]
        if test -z "$ws"
            echo "usage: closews <workspace>" >&2
            return 1
        end
        set -l batch (hyprctl clients -j | jq -r --arg ws "$ws" '
          [.[] | select((.workspace.id | tostring) == $ws) |
            "dispatch hl.dsp.window.close({ window = \"address:" + .address + "\" })"
          ] | join(" ; ")
        ')
        if test -z "$batch"
            return 0
        end
        hyprctl --batch $batch
      '';

      # IVPN status with polling until connected
      ivs = ''
        while true
            set -l vpn_status (ivpn status | string collect)
            echo $vpn_status
            if echo $vpn_status | grep -q "Connected"
                break
            end
            sleep 1
        end
      '';
    };
  };
}
