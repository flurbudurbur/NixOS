{ config, pkgs, ... }:

{
	home.username = "flur";
	home.homeDirectory = "/home/flur";
	programs.git.enable = true;
	home.stateVersion = "25.11";
	programs.bash = {
		enable = true;
		shellAliases = {
			btw = "echo I use Nixos, btw";
		};
	};
}
