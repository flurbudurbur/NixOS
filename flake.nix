{
	description = "nixos for flur";
	inputs = {
		nixpkgs.url = "nixpkgs/nixos-25.11";
		nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
		zen-browser = {
			url = "github:0xc000022070/zen-browser-flake";
			inputs = {
				# IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
				# to have it up-to-date or simply don't specify the nixpkgs input
				nixpkgs.follows = "nixpkgs";
				home-manager.follows = "home-manager";
			};
		};
    nixcord = {
      url = "github:FlameFlag/nixcord";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
		home-manager = {
			url = "github:nix-community/home-manager/release-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nix-flatpak = {
			url = "github:gmodena/nix-flatpak?ref=latest";
		};
		nixvim = {
			url = "github:nix-community/nixvim/nixos-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		# Add hypridle from main branch to fix D-Bus crash after suspend
		hypridle = {
			url = "github:hyprwm/hypridle";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = inputs@{ self, nixpkgs, home-manager, zen-browser, nix-flatpak, nixvim, hypridle, ... }: {
		nixosConfigurations.flurPC = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
				./hosts/flurPC/hardware-configuration.nix
				./configuration.nix
				home-manager.nixosModules.home-manager
				{
					home-manager = {
						useGlobalPkgs = true;
						useUserPackages = true;
						users.flur = import ./home.nix;
						extraSpecialArgs = {
							hostname = "flurPC";
							hypridle = hypridle.packages.x86_64-linux.default;
						};
						backupFileExtension = "backup";
						sharedModules = [
							zen-browser.homeModules.default
							nix-flatpak.homeManagerModules.nix-flatpak
						  nixvim.homeModules.nixvim
              inputs.nixcord.homeModules.nixcord
						];
					};
				}
			];
		};
	};
}
