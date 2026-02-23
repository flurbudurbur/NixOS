{ pkgs, nixpkgs-unstable, ... }:

{
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    keyMode = "vi";
    prefix = "C-Space";
    baseIndex = 1;
    escapeTime = 0;
    mouse = true;

    extraConfig = ''
      # True color support
      set-option -sa terminal-overrides ",xterm*:Tc"

      # Unbind default prefix
      unbind C-b

      # Vim-like pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Vim-like window navigation
      bind -n M-h previous-window
      bind -n M-l next-window

      # Split windows using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

      # Resize panes with vim-like keys
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Start windows and panes at 1, not 0
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Vi mode for copy mode
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-closing-target

      # Rose Pine theme configuration
      set -g @rose_pine_variant 'moon'

      # My own additions
      set-option -g status-position top
      set -g status-justify absolute-centre
      set -g detach-on-destroy off

      # Sesh session manager
      unbind s
      bind-key s run-shell "sesh connect \"$( \
        sesh list | fzf-tmux -p 55%,60% \
          --no-sort --border-label ' sesh ' --prompt '⚡  ' \
          --header ' ^a all ^t tmux ^g configs ^x zoxide ^d kill ^f find' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list)' \
          --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t)' \
          --bind 'ctrl-g:change-prompt(⚙️   )+reload(sesh list -c)' \
          --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z)' \
          --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
          --bind 'ctrl-d:execute(tmux kill-session -t {})+change-prompt(⚡  )+reload(sesh list)' \
      )\""
      bind-key L run-shell "sesh last"
    '';

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
      rose-pine
    ];
  };

  # Install tmuxinator from unstable (3.3.7)
  home.packages = with nixpkgs-unstable; [
    tmuxinator
  ];

  # Tmuxinator project configs managed by Nix
  xdg.configFile."tmuxinator/netmon.yml".text = ''
    name: netmon
    root: ~

    windows:
      - overview:
          layout: even-horizontal
          panes:
            - bandwhich
            - iftop
      - processes: nethogs
  '';

  xdg.configFile."tmuxinator/dev.yml".text = ''
    name: dev
    root: .

    windows:
      - code:
          layout: main-vertical
          panes:
            - nvim .
            - claude
      - git: lazygit
      - scratch:
  '';

  # Discord and Music player
  xdg.configFile."tmuxinator/disqo.yml".text = ''
    name: disqo
    root: ~

    windows:
      - media:
          layout: main-vertical
          panes:
            - oxicord
            - kew all --nocover
            - qobuz-player
          post: tmux resize-pane -t 2 -y 30%
  '';
}
