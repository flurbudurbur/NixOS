{ config, pkgs, hostname, ... }:

let
	c = import ./colors.nix;
in
{
	imports = [
		(import ./hyprland.nix { inherit hostname; })
		./hyprlock.nix
		./hypridle.nix
		./waybar.nix
		./walker.nix
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
			pwvucontrol
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
			gtk-theme = "rose-pine-moon";
			icon-theme = "rose-pine-moon";
			cursor-theme = "BreezeX-RosePine-Linux";
			cursor-size = 24;
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
				palette = "rose-pine-moon";
				palettes.rose-pine-moon = {
					base = c.base;
					surface = c.surface;
					overlay = c.overlay;
					muted = c.muted;
					subtle = c.subtle;
					text = c.text;
					love = c.love;
					gold = c.gold;
					rose = c.rose;
					pine = c.pine;
					foam = c.foam;
					iris = c.iris;
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
						foreground = c.text;
						background = c.base;
					};
					cursor = {
						text = c.text;
						cursor = c.highlightHigh;
					};
					selection = {
						text = c.text;
						background = c.highlightMed;
					};
					normal = {
						black = c.ansi.black;
						red = c.ansi.red;
						green = c.ansi.green;
						yellow = c.ansi.yellow;
						blue = c.ansi.blue;
						magenta = c.ansi.magenta;
						cyan = c.ansi.cyan;
						white = c.ansi.white;
					};
					bright = {
						black = c.ansi.brightBlack;
						red = c.ansi.brightRed;
						green = c.ansi.brightGreen;
						yellow = c.ansi.brightYellow;
						blue = c.ansi.brightBlue;
						magenta = c.ansi.brightMagenta;
						cyan = c.ansi.brightCyan;
						white = c.ansi.brightWhite;
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
				# Rose Pine Moon theme
				foreground = c.text;
				background = c.base;
				selection_foreground = c.text;
				selection_background = c.highlightMed;
				cursor = c.highlightHigh;
				cursor_text_color = c.text;
				url_color = c.iris;

				# Black
				color0 = c.ansi.black;
				color8 = c.ansi.brightBlack;

				# Red
				color1 = c.ansi.red;
				color9 = c.ansi.brightRed;

				# Green
				color2 = c.ansi.green;
				color10 = c.ansi.brightGreen;

				# Yellow
				color3 = c.ansi.yellow;
				color11 = c.ansi.brightYellow;

				# Blue
				color4 = c.ansi.blue;
				color12 = c.ansi.brightBlue;

				# Magenta
				color5 = c.ansi.magenta;
				color13 = c.ansi.brightMagenta;

				# Cyan
				color6 = c.ansi.cyan;
				color14 = c.ansi.brightCyan;

				# White
				color7 = c.ansi.white;
				color15 = c.ansi.brightWhite;

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
