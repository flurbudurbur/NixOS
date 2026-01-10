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
				background-color: rgba(25, 23, 36, 0.9);
				color: #e0def4;
			}

			#workspaces {
				/* Workspaces are horizontal by default in Waybar */
			}

			#workspaces button {
				padding: 0 5px;
				color: #e0def4;
				background: transparent;
				border: none;
				min-width: 20px;
			}

			#workspaces button.active {
				color: #ebbcba;
				background: rgba(235, 188, 186, 0.2);
			}

			#workspaces button:hover {
				background: rgba(235, 188, 186, 0.1);
			}

			#clock {
				color: #c4a7e7;
			}

			#cpu {
				color: #eb6f92;
			}

			#memory {
				color: #f6c177;
			}

			#network {
				color: #9ccfd8;
			}

			#pulseaudio {
				color: #31748f;
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
