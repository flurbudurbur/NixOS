{ ... }:

{
  # Disabled due to upstream issue #166: https://github.com/FlameFlag/nixcord/issues/166
  # Using oxicord (TUI Discord) instead - see shell/tmux.nix disco session
  programs.nixcord = {
    enable = false;

    # Configuration preserved for when upstream issue is resolved
    discord.vencord.enable = true;
    config = {
      themeLinks = [
        "https://raw.githubusercontent.com/rose-pine/discord/refs/heads/main/dist/rose-pine-moon.css"
      ];
      useQuickCss = true;
    };
  };
}
