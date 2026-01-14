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
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord.url = "github:FlameFlag/nixcord/5de40d608552b2c7967230a0f2a2dc381686241e";
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

	outputs = inputs @ {
    nixpkgs,
    home-manager,
    stylix,
    ...
    }: {
		nixosConfigurations = {
      flurPC = let
          username = "flur";
        in
          nixpkgs.lib.nixosSystem {
		    	  system = "x86_64-linux";
			      modules = [
				      ./hosts/flurPC
				      ./users/${username}/nixos.nix
              stylix.nixosModules.stylix
              # Stylix/home-manager issue
              # Follow issues: 
              # - https://github.com/nix-community/home-manager/pull/6172
              # - https://github.com/nix-community/stylix/issues/865
              { nixpkgs.config.allowUnfree = true; }
			    	  home-manager.nixosModules.home-manager
				      {
				    	  home-manager = {
				    		  useGlobalPkgs = true;
				    		  useUserPackages = true;
				    		  users.${username} = import ./users/${username}/home.nix;
				    		  extraSpecialArgs = {
					      		hostname = "flurPC";
					          hypridle = inputs.hypridle.packages.x86_64-linux.default;
				    	  	};
					      	backupFileExtension = "backup";
					  	    sharedModules = let
					  		    inherit (inputs) zen-browser nix-flatpak nixvim nixcord stylix;
					  	    in [
					  		    zen-browser.homeModules.default
					  		    nix-flatpak.homeManagerModules.nix-flatpak
					  		    nixvim.homeModules.nixvim
					  		    nixcord.homeModules.nixcord
					  		    stylix.homeModules.stylix
					  	    ];
					      };
			        }
            ];
      };
    };
	};
}
