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
		./fastfetch.nix
		./nvim.nix
	];

	home = {
		username = "flur";
		homeDirectory = "/home/flur";

		sessionVariables = {
			XDG_DATA_DIRS = "$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
		};

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
			nautilus
			file-roller
			unzip
			zip
			p7zip
			unrar
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
		gtk3.extraCss = ''
			@define-color accent_bg_color ${c.iris};
			@define-color accent_fg_color ${c.base};
			@define-color accent_color ${c.iris};
			@define-color destructive_bg_color ${c.love};
			@define-color destructive_fg_color ${c.base};
			@define-color destructive_color ${c.love};
			@define-color success_bg_color ${c.foam};
			@define-color success_fg_color ${c.text};
			@define-color success_color ${c.foam};
			@define-color warning_bg_color ${c.gold};
			@define-color warning_fg_color ${c.text};
			@define-color warning_color ${c.gold};
			@define-color error_bg_color ${c.love};
			@define-color error_fg_color ${c.text};
			@define-color error_color ${c.love};
			@define-color window_bg_color ${c.base};
			@define-color window_fg_color ${c.text};
			@define-color view_bg_color ${c.surface};
			@define-color view_fg_color ${c.text};
			@define-color headerbar_bg_color ${c.base};
			@define-color headerbar_fg_color ${c.text};
			@define-color headerbar_backdrop_color @window_bg_color;
			@define-color headerbar_shade_color ${c.base};
			@define-color headerbar_border_color ${c.highlightMed};
			@define-color card_bg_color ${c.overlay};
			@define-color card_fg_color ${c.text};
			@define-color card_shade_color ${c.overlay};
			@define-color dialog_bg_color ${c.surface};
			@define-color dialog_fg_color ${c.text};
			@define-color popover_bg_color ${c.surface};
			@define-color popover_fg_color ${c.text};
			@define-color sidebar_bg_color ${c.surface};
			@define-color sidebar_fg_color ${c.text};
			@define-color sidebar_backdrop_color ${c.surface};
			@define-color sidebar_shade_color ${c.surface};
		'';
		gtk4.extraCss = ''
			@define-color accent_bg_color ${c.iris};
			@define-color accent_fg_color ${c.base};
			@define-color accent_color ${c.iris};
			@define-color destructive_bg_color ${c.love};
			@define-color destructive_fg_color ${c.base};
			@define-color destructive_color ${c.love};
			@define-color success_bg_color ${c.foam};
			@define-color success_fg_color ${c.text};
			@define-color success_color ${c.foam};
			@define-color warning_bg_color ${c.gold};
			@define-color warning_fg_color ${c.text};
			@define-color warning_color ${c.gold};
			@define-color error_bg_color ${c.love};
			@define-color error_fg_color ${c.text};
			@define-color error_color ${c.love};
			@define-color window_bg_color ${c.base};
			@define-color window_fg_color ${c.text};
			@define-color view_bg_color ${c.surface};
			@define-color view_fg_color ${c.text};
			@define-color headerbar_bg_color ${c.base};
			@define-color headerbar_fg_color ${c.text};
			@define-color headerbar_backdrop_color @window_bg_color;
			@define-color headerbar_shade_color ${c.base};
			@define-color headerbar_border_color ${c.highlightMed};
			@define-color card_bg_color ${c.overlay};
			@define-color card_fg_color ${c.text};
			@define-color card_shade_color ${c.overlay};
			@define-color dialog_bg_color ${c.surface};
			@define-color dialog_fg_color ${c.text};
			@define-color popover_bg_color ${c.surface};
			@define-color popover_fg_color ${c.text};
			@define-color shade_color rgba(0, 0, 0, 0.36);
			@define-color scrollbar_outline_color rgba(0, 0, 0, 0.5);
			@define-color sidebar_bg_color ${c.surface};
			@define-color sidebar_fg_color ${c.text};
			@define-color sidebar_backdrop_color ${c.surface};
			@define-color sidebar_shade_color ${c.surface};
			@define-color secondary_sidebar_bg_color ${c.base};
			@define-color secondary_sidebar_fg_color ${c.text};
			@define-color secondary_sidebar_backdrop_color ${c.base};
			@define-color secondary_sidebar_shade_color ${c.base};
			@define-color thumbnail_bg_color ${c.surface};
			@define-color thumbnail_fg_color ${c.text};
		'';
	};

	qt = {
		enable = true;
		platformTheme.name = "gtk";
		style.name = "gtk2";
	};

	xdg.mimeApps = {
		enable = true;
		defaultApplications = {
			"inode/directory" = [ "org.gnome.Nautilus.desktop" ];
		};
	};

	# Configure XDG portal backend preferences for Hyprland
	xdg.configFile."xdg-desktop-portal/hyprland-portals.conf".text = ''
		[preferred]
		default=hyprland;gtk
		org.freedesktop.impl.portal.FileChooser=gtk
		org.freedesktop.impl.portal.OpenURI=gtk
		org.freedesktop.impl.portal.Settings=gtk
	'';

	dconf.settings = {
		"org/gnome/desktop/interface" = {
			color-scheme = "prefer-dark";
			gtk-theme = "rose-pine-moon";
			icon-theme = "rose-pine-moon";
			cursor-theme = "BreezeX-RosePine-Linux";
			cursor-size = 24;
		};
	};

	# GNOME Keyring for secrets/passwords
	services.gnome-keyring = {
		enable = true;
		components = [ "pkcs11" "secrets" "ssh" ];
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

			initContent = ''
				# Display system info with fastfetch
				fastfetch

				# Auto-start tmuxinator "dev" session when opening a terminal
				# Only if not already inside a tmux session (prevent nesting)
				if [[ -z "$TMUX" ]]; then
					# Check if tmuxinator is available
					if command -v tmuxinator &> /dev/null; then
						# Attach to existing "dev" session, or start it if it doesn't exist
						tmuxinator start dev 2>/dev/null || true
					fi
				fi
			'';
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
					host = "console.flur.dev";
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
    btop.settings = {
      theme_background = false;
      vim_keys = true;
      rounded_corners = false;
    };
		home-manager.enable = true;
		zen-browser.enable = true;
	};

	services.flatpak = {
		enable = true;

		# Auto-update Flatpaks on system rebuild
		update.onActivation = true;

		# Configure Flathub remote
		remotes = [
			{
				name = "flathub";
				location = "https://flathub.org/repo/flathub.flatpakrepo";
			}
		];

		# Declaratively managed Flatpak applications
		packages = [
			"com.usebottles.bottles"
		];

		# Add overrides for better portal integration
		overrides = {
			"com.usebottles.bottles" = {
				Context = {
					filesystems = [
						"xdg-config/gtk-3.0:ro"  # Allow reading GTK configs
						"xdg-run/dconf"          # Allow dconf access
					];
				};
				Environment = {
					GTK_USE_PORTAL = "1";  # Explicitly enable portal usage
				};
			};
		};
	};
}
