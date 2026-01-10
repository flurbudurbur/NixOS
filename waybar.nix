{
	programs.waybar = {
		enable = true;
		systemd.enable = true;
		systemd.target = "hyprland-session.target";
		settings = {
			mainBar = {
				layer = "top";
				position = "top";
				height = 30;
				spacing = 4;
				modules-left = [ "hyprland/workspaces" "hyprland/window" ];
				modules-center = [ "clock" ];
				modules-right = [ "pulseaudio" "network" "cpu" "memory" "tray" ];

				"hyprland/workspaces" = {
					format = "{name}";
					on-click = "activate";
				};

				"hyprland/window" = {
					max-length = 50;
				};

				clock = {
					format = "{:%H:%M}";
					format-alt = "{:%Y-%m-%d %H:%M}";
					tooltip-format = "<tt><small>{calendar}</small></tt>";
				};

				cpu = {
					format = "CPU {usage}%";
					tooltip = true;
				};

				memory = {
					format = "MEM {}%";
				};

				network = {
					format-wifi = "WiFi {signalStrength}%";
					format-ethernet = "ETH";
					format-disconnected = "Disconnected";
					tooltip-format = "{ifname}: {ipaddr}";
				};

				pulseaudio = {
					format = "VOL {volume}%";
					format-muted = "MUTED";
					on-click = "pavucontrol";
				};

				tray = {
					spacing = 10;
				};
			};
		};
		style = ''
			* {
				font-family: monospace;
				font-size: 13px;
			}

			window#waybar {
				background-color: rgba(30, 30, 46, 0.9);
				color: #cdd6f4;
			}

			#workspaces {
				/* Workspaces are horizontal by default in Waybar */
			}

			#workspaces button {
				padding: 0 5px;
				color: #cdd6f4;
				background: transparent;
				border: none;
				min-width: 20px;
			}

			#workspaces button.active {
				color: #89b4fa;
				background: rgba(137, 180, 250, 0.2);
			}

			#workspaces button:hover {
				background: rgba(137, 180, 250, 0.1);
			}

			#clock, #cpu, #memory, #network, #pulseaudio, #tray {
				padding: 0 10px;
			}

			#tray > .passive {
				-gtk-icon-effect: dim;
			}
		'';
	};
}
