{
	description = "nixos for flur";
	inputs = {
		nixpkgs.url = "nixpkgs/nixos-25.11";
		zen-browser = {
			url = "github:0xc000022070/zen-browser-flake";
			inputs = {
				# IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
				# to have it up-to-date or simply don't specify the nixpkgs input
				nixpkgs.follows = "nixpkgs";
				home-manager.follows = "home-manager";
			};
		};
		home-manager = {
			url = "github:nix-community/home-manager/release-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, home-manager, zen-browser, ... }: {
		nixosConfigurations.flurPC = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
				./configuration.nix
				home-manager.nixosModules.home-manager
				{
					home-manager = {
						useGlobalPkgs = true;
						useUserPackages = true;
						users.flur = import ./home.nix;
						extraSpecialArgs = { hostname = "flurPC"; };
						backupFileExtension = "backup";
						sharedModules = [
							zen-browser.homeModules.default
						];
					};
				}
			];
		};
	};
}
