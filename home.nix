{ config, pkgs, ... }:

{
	home.username = "flur";
	home.homeDirectory = "/home/flur";
	programs.git = {
		enable = true;
		settings = {
			user.email = "69259138+flurbudurbur@users.noreply.github.com";
			user.name = "flurbudurbur";
			init.defaultBranch = "main";
		};
	};
	home.stateVersion = "25.11";
	programs.bash = {
		enable = true;
		shellAliases = {
			btw = "echo I use Nixos, btw";
		};
	};
	programs.ssh = {
		enable = true;
		matchBlocks = {
			"github.com" = {
				identityFile = "~/.ssh/github";
			};
		};
	};
}
