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
		zsh = {
			enable = true;
			enableCompletion = true;
			autosuggestion.enable = true;
			syntaxHighlighting.enable = true;
			history = {
				size = 10000;
				save = 10000;
			};
			shellAliases = {
				btw = "echo I use Nixos, btw";
				nrt = "nixos-rebuild test --sudo --flake /home/flur/nixos-system";
				nrs = "nixos-rebuild switch --sudo --flake /home/flur/nixos-system";
			};
			oh-my-zsh = {
				enable = true;
				plugins = [ "git" "sudo" "tmux" "podman" ];
			};
		};
		starship = {
			enable = true;
			enableZshIntegration = true;
			settings = {
				palette = "rose-pine";
				palettes.rose-pine = {
					base = "#191724";
					surface = "#1f1d2e";
					overlay = "#26233a";
					muted = "#6e6a86";
					subtle = "#908caa";
					text = "#e0def4";
					love = "#eb6f92";
					gold = "#f6c177";
					rose = "#ebbcba";
					pine = "#31748f";
					foam = "#9ccfd8";
					iris = "#c4a7e7";
				};
				format = "$directory$git_branch$git_status$character";
				character = {
					success_symbol = "[➜](foam)";
					error_symbol = "[➜](love)";
				};
				directory = {
					style = "bold iris";
				};
				git_branch = {
					style = "bold rose";
				};
				git_status = {
					style = "bold gold";
				};
			};
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
				terminal.shell = "${pkgs.zsh}/bin/zsh";
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
				# Enable ligatures
				disable_ligatures = "never";
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
