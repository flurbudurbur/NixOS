{ ... }:

{
  programs.nixcord = {
    enable = true;

    # Enable Vesktop client (user's preference)
    # vesktop.enable = true;

    # Enable Vencord (default Discord client with mods)
    discord.vencord.enable = true;

    # Configuration
    config = {
      # Load rose-pine theme from official URL
      themeLinks = [
        "https://raw.githubusercontent.com/rose-pine/discord/refs/heads/main/dist/rose-pine-moon.css"
      ];

      # Enable custom CSS support
      useQuickCss = true;
    };
  };
}
