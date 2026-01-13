let
	c = import ../../../modules/colors.nix;
in
{
	programs.waybar = {
		enable = true;
		systemd.enable = true;
		systemd.target = "graphical-session.target";
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
					on-click = "pwvucontrol";
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
				background-color: ${c.rgba c.base "0.9"};
				color: ${c.text};
			}

			#workspaces {
				/* Workspaces are horizontal by default in Waybar */
			}

			#workspaces button {
				padding: 0 5px;
				color: ${c.text};
				background: transparent;
				border: none;
				min-width: 20px;
			}

			#workspaces button.active {
				color: ${c.rose};
				background: ${c.rgba c.rose "0.2"};
			}

			#workspaces button:hover {
				background: ${c.rgba c.rose "0.1"};
			}

			#clock {
				color: ${c.iris};
			}

			#cpu {
				color: ${c.love};
			}

			#memory {
				color: ${c.gold};
			}

			#network {
				color: ${c.foam};
			}

			#pulseaudio {
				color: ${c.pine};
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
