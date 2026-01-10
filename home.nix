{ config, pkgs, hostname, ... }:

{
	imports = [
		(import ./hyprland.nix { inherit hostname; })
		./hyprlock.nix
		./waybar.nix
		./hyprlauncher.nix
		./tmux.nix
	];

	home = {
		username = "flur";
		homeDirectory = "/home/flur";

		packages = with pkgs; [
			rose-pine-gtk-theme
			rose-pine-icon-theme
			discord
			lazygit
			gnupg
			claude-code
			hyprpaper
			teams-for-linux
			xplr
			pavucontrol
		];

		pointerCursor = {
			name = "BreezeX-RosePine-Linux";
			package = pkgs.rose-pine-cursor;
			size = 24;
			gtk.enable = true;
			x11.enable = true;
		};

		stateVersion = "25.11";
	};

	gtk = {
		enable = true;
		theme = {
			name = "rose-pine-moon";
			package = pkgs.rose-pine-gtk-theme;
		};
		iconTheme = {
			name = "rose-pine-moon";
			package = pkgs.rose-pine-icon-theme;
		};
	};

	qt = {
		enable = true;
		platformTheme.name = "gtk";
		style.name = "gtk2";
	};

	dconf.settings = {
		"org/gnome/desktop/interface" = {
			color-scheme = "prefer-dark";
		};
	};

	services.hyprpaper = {
		enable = true;
		settings = {
			preload = [
				"~/.config/wallpapers/wallpaper.jpg"
			];
			wallpaper = [
				",~/.config/wallpapers/wallpaper.jpg"
			];
		};
	};

	programs = {
		git = {
			enable = true;
			settings = {
				user.email = "69259138+flurbudurbur@users.noreply.github.com";
				user.name = "flurbudurbur";
				init.defaultBranch = "main";
			};
		};
		bash = {
			enable = true;
			shellAliases = {
				btw = "echo I use Nixos, btw";
				nrt = "nixos-rebuild test --sudo --flake /home/flur/nixos-system";
				nrs = "nixos-rebuild switch --sudo --flake /home/flur/nixos-system";
			};
			initExtra = ''
			# Oh My Bash
			export OSH="${config.home.homeDirectory}/.oh-my-bash"

			# Rose Pine theme colors
			OSH_THEME="robbyrussell"

			# Uncomment the following line to enable command auto-correction.
			ENABLE_CORRECTION="true"

			# Completions
			completions=(
				git
				ssh
			)

			# Aliases
			aliases=(
				general
			)

			# Plugins
			plugins=(
				git
				bash-preexec
			)

			# Source Oh My Bash if installed
			if [ -f "$OSH/oh-my-bash.sh" ]; then
				source "$OSH/oh-my-bash.sh"
			fi

			# Rose Pine color palette for terminal
			export ROSE_PINE_BASE="#191724"
			export ROSE_PINE_SURFACE="#1f1d2e"
			export ROSE_PINE_OVERLAY="#26233a"
			export ROSE_PINE_MUTED="#6e6a86"
			export ROSE_PINE_SUBTLE="#908caa"
			export ROSE_PINE_TEXT="#e0def4"
			export ROSE_PINE_LOVE="#eb6f92"
			export ROSE_PINE_GOLD="#f6c177"
			export ROSE_PINE_ROSE="#ebbcba"
			export ROSE_PINE_PINE="#31748f"
			export ROSE_PINE_FOAM="#9ccfd8"
			export ROSE_PINE_IRIS="#c4a7e7"
		'';
		};
		ssh = {
			enableDefaultConfig = false;
			enable = true;
			matchBlocks = {
				"*" = {
					addKeysToAgent = "yes";
				};
				"github.com" = {
					identityFile = "~/.ssh/github";
				};
				"shiori" = {
					identityFile = "~/.ssh/shiori";
					user = "flur";
				};
			};
		};
		alacritty = {
			enable = true;
			settings = {
				font = {
					normal = {
						family = "FiraCode Nerd Font";
						style = "Regular";
					};
					bold = {
						family = "FiraCode Nerd Font";
						style = "Bold";
					};
					italic = {
						family = "FiraCode Nerd Font";
						style = "Italic";
					};
					size = 12;
				};
				window = {
					padding = {
						x = 10;
						y = 10;
					};
					opacity = 0.95;
				};
				colors = {
					primary = {
						foreground = "#e0def4";
						background = "#191724";
					};
					cursor = {
						text = "#e0def4";
						cursor = "#524f67";
					};
					selection = {
						text = "#e0def4";
						background = "#403d52";
					};
					normal = {
						black = "#26233a";
						red = "#eb6f92";
						green = "#31748f";
						yellow = "#f6c177";
						blue = "#9ccfd8";
						magenta = "#c4a7e7";
						cyan = "#ebbcba";
						white = "#e0def4";
					};
					bright = {
						black = "#6e6a86";
						red = "#eb6f92";
						green = "#31748f";
						yellow = "#f6c177";
						blue = "#9ccfd8";
						magenta = "#c4a7e7";
						cyan = "#ebbcba";
						white = "#e0def4";
					};
				};
			};
		};
		kitty = {
			enable = true;
			font = {
				name = "FiraCode Nerd Font";
				size = 12;
			};
			settings = {
				# Rose Pine theme
				foreground = "#e0def4";
				background = "#191724";
				selection_foreground = "#e0def4";
				selection_background = "#403d52";
				cursor = "#524f67";
				cursor_text_color = "#e0def4";
				url_color = "#c4a7e7";

				# Black
				color0 = "#26233a";
				color8 = "#6e6a86";

				# Red
				color1 = "#eb6f92";
				color9 = "#eb6f92";

				# Green
				color2 = "#31748f";
				color10 = "#31748f";

				# Yellow
				color3 = "#f6c177";
				color11 = "#f6c177";

				# Blue
				color4 = "#9ccfd8";
				color12 = "#9ccfd8";

				# Magenta
				color5 = "#c4a7e7";
				color13 = "#c4a7e7";

				# Cyan
				color6 = "#ebbcba";
				color14 = "#ebbcba";

				# White
				color7 = "#e0def4";
				color15 = "#e0def4";

				# Window settings
				window_padding_width = 10;
				background_opacity = "0.95";
				confirm_os_window_close = 0;
			};
		};
		home-manager.enable = true;
		zen-browser.enable = true;
	};
}
