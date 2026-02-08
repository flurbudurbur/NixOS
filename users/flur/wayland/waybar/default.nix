{ colors, ... }:

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
				modules-left = [ "hyprland/workspaces" "hyprland/window" "mpris" ];
				modules-center = [ "clock" ];
				modules-right = [ "custom/notification" "wireplumber" "bluetooth" "network" "cpu" "memory" "tray" ];

				"hyprland/workspaces" = {
					format = "{name}";
					on-click = "activate";
				};

				"hyprland/window" = {
					max-length = 50;
					separate-outputs = true;
				};

				mpris = {
					format = "{player_icon} {title} - {artist}";
					format-paused = "{status_icon} {title} - {artist}";
					player-icons = {
						default = "";
						spotify = "";
						firefox = "";
					};
					status-icons = {
						playing = "";
						paused = "";
					};
					max-length = 60;
					on-click = "playerctl play-pause";
					on-click-right = "playerctl next";
					on-scroll-up = "playerctl previous";
					on-scroll-down = "playerctl next";
				};

				"custom/notification" = {
					tooltip = false;
					format = "{icon} {}";
					format-icons = {
						notification = "<span foreground='${colors.love}'><sup></sup></span>";
						none = "";
						dnd-notification = "<span foreground='${colors.love}'><sup></sup></span>";
						dnd-none = "";
						inhibited-notification = "<span foreground='${colors.love}'><sup></sup></span>";
						inhibited-none = "";
						dnd-inhibited-notification = "<span foreground='${colors.love}'><sup></sup></span>";
						dnd-inhibited-none = "";
					};
					return-type = "json";
					exec = "${../../../../modules/custom/scripts/dunst-status.sh}";
					on-click = "dunstctl history-pop";
					on-click-right = "dunstctl close-all";
					on-click-middle = "dunstctl set-paused toggle";
					restart-interval = 1;
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
					format-wifi = "WIFI {signalStrength}%";
					format-ethernet = "ETH";
					format-disconnected = "DISC";
					tooltip-format = "{ifname}: {ipaddr}";
				};

				wireplumber = {
					format = "VOL {volume}%";
					format-muted = " MUTED";
					format-icons = [ "" "" "" ];
					on-click = "pwvucontrol";
					on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
					scroll-step = 1;
					tooltip-format = "{node_name}";
				};

				bluetooth = {
					format = "BT ON";
					format-connected = "BT {num_connections}";
					format-connected-battery = "BT {device_battery_percentage}%";
					format-disabled = "BT DISABLED";
					format-off = "BT OFF";
					tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} CONNECTED";
					tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} CONNECTED\n\n{device_enumerate}";
					tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
					tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
          #on-click = "overskride";
				};

				tray = {
					spacing = 10;
				};
			};
		};
		style = ''
			* {
				font-family: "Bricolage Grotesque", sans-serif;
				font-size: 13px;
				border: none;
				border-radius: 0;
			}

			window#waybar {
				background-color: transparent;
			}

			.modules-left, .modules-center, .modules-right {
				background-color: ${colors.rgba colors.base "0.9"};
				border-radius: 10px;
				margin-top: 10px;
				margin-left: 10px;
				margin-right: 10px;
				margin-bottom: 0;
				padding: 0 10px;
				transition: all 0.3s ease-in-out;
			}

			#workspaces button {
				padding: 0 5px;
				color: ${colors.text};
				background: transparent;
				border: none;
				min-width: 20px;
			}

			#workspaces button.active {
				color: ${colors.rose};
				background: ${colors.rgba colors.rose "0.2"};
				border: none;
			}

			#workspaces button:hover {
				background: ${colors.rgba colors.rose "0.1"};
			}

			#window {
				color: ${colors.text};
			}

			#mpris {
				color: ${colors.rose};
			}

			#mpris.paused {
				color: ${colors.muted};
			}

			#custom-notification {
				color: ${colors.text};
			}

			#clock {
				color: ${colors.iris};
			}

			#cpu {
				color: ${colors.love};
			}

			#memory {
				color: ${colors.gold};
			}

			#network {
				color: ${colors.foam};
			}

			#wireplumber {
				color: ${colors.pine};
			}

			#bluetooth {
				color: ${colors.iris};
			}

			#bluetooth.disabled,
			#bluetooth.off {
				color: ${colors.muted};
			}

			#tray {
				color: ${colors.text};
			}

			#clock, #cpu, #memory, #network, #wireplumber, #bluetooth, #tray, #window, #mpris, #custom-notification {
				padding: 0 10px;
			}

			#tray > .passive {
				-gtk-icon-effect: dim;
			}
		'';
	};
}
