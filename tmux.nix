{ pkgs, ... }:

let
  c = import ./colors.nix;
in
{
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    keyMode = "vi";
    prefix = "C-Space";
    baseIndex = 1;
    escapeTime = 0;
    mouse = true;

    # Enable tmuxinator
    tmuxinator.enable = true;

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

      # Status bar styling (Rose Pine Moon)
      set -g status-style 'bg=${c.base} fg=${c.text}'
      set -g status-left '#[bg=${c.rose},fg=${c.base},bold] #S #[bg=${c.base}] '
      set -g status-right '#[bg=${c.overlay},fg=${c.text}] %Y-%m-%d %H:%M '
      set -g window-status-current-style 'bg=${c.highlightMed},fg=${c.text},bold'
      set -g window-status-style 'bg=${c.base},fg=${c.muted}'
      set -g pane-border-style 'fg=${c.overlay}'
      set -g pane-active-border-style 'fg=${c.rose}'
    '';

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
    ];
  };

  # Tmuxinator project configs managed by Nix
  xdg.configFile."tmuxinator/dev.yml".text = ''
    name: dev
    root: ~/Developer

    windows:
      - code:
          layout: main-vertical
          panes:
            -
            -
      - git: lazygit
      - sys: btop
      - scratch:
  '';
}
