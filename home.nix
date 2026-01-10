{ config, pkgs, hostname, ... }:

{
	imports = [
		(import ./hyprland.nix { inherit hostname; })
		./hyprlock.nix
		./waybar.nix
		./hyprlauncher.nix
	];

	home = {
		username = "flur";
		homeDirectory = "/home/flur";

		packages = with pkgs; [
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
			name = "BreezeX-RosePine";
			package = pkgs.rose-pine-cursor;
			size = 24;
			gtk.enable = true;
			x11.enable = true;
		};

		stateVersion = "25.11";
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
		kitty.enable = true;
		home-manager.enable = true;
		zen-browser.enable = true;
	};
}
