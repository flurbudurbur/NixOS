{ config, pkgs, ... }:

{
	home.username = "flur";
	home.homeDirectory = "/home/flur";
	programs.git = {
		enable = true;
		userEmail = "69259138+flurbudurbur@users.noreply.github.com";
		userName = "flurbudurbur";
		extraConfig = {
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
