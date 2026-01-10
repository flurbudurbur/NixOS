{ config, pkgs, ... }:

{
	home.packages = [ pkgs.hyprlauncher ];

	xdg.configFile."hyprlauncher/config.toml".text = ''
		[general]
		# Show icons next to application names
		show_icons = true
		# Maximum number of entries to show
		max_entries = 10
	'';

	xdg.configFile."hyprlauncher/style.css".text = ''
		/* Waybar-inspired Catppuccin theme */
		window {
			background-color: rgba(30, 30, 46, 0.9);
			border-radius: 10px;
			border: 2px solid rgba(137, 180, 250, 0.3);
		}

		entry {
			font-family: monospace;
			font-size: 13px;
			color: #cdd6f4;
			background-color: transparent;
			border: none;
			padding: 8px 12px;
			margin: 8px;
			border-radius: 6px;
			background-color: rgba(30, 30, 46, 0.5);
		}

		entry:focus {
			outline: none;
			border: none;
		}

		#list {
			background-color: transparent;
			margin: 0 8px 8px 8px;
		}

		#list row {
			padding: 8px 12px;
			color: #cdd6f4;
			font-family: monospace;
			font-size: 13px;
			border-radius: 6px;
			margin: 2px 0;
		}

		#list row:selected {
			background-color: rgba(137, 180, 250, 0.2);
			color: #89b4fa;
		}

		#list row:hover {
			background-color: rgba(137, 180, 250, 0.1);
		}

		/* Application icon styling */
		image {
			margin-right: 8px;
		}

		/* Scrollbar styling */
		scrollbar {
			background-color: transparent;
		}

		scrollbar slider {
			background-color: rgba(137, 180, 250, 0.3);
			border-radius: 4px;
			min-width: 6px;
		}

		scrollbar slider:hover {
			background-color: rgba(137, 180, 250, 0.5);
		}
	'';
}
