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
    nixcord.url = "github:FlameFlag/nixcord";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    oxicord.url = "github:linuxmobile/oxicord";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-secrets = {
      url = "git+ssh://git@github.com/flurbudurbur/nix-secrets?shallow=1&ref=main";
      flake = true;
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      stylix,
      sops-nix,
      nixos-secrets,
      ...
    }:
    let
      colors = import ./modules/colors.nix;
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
      nixosConfigurations = {
        flurPC =
          let
            username = "flur";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./hosts/flurPC
              ./users/${username}/nixos.nix
              stylix.nixosModules.stylix
              sops-nix.nixosModules.sops
              # Stylix/home-manager issue
              # Follow issues:
              # - https://github.com/nix-community/home-manager/pull/6172
              # - https://github.com/nix-community/stylix/issues/865
              {
                nixpkgs.config.allowUnfree = true;
                nixpkgs.overlays = [
                  inputs.nur.overlays.default
                ];
              }
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${username} = {
                    imports = [
                      ./users/${username}/home.nix
                    ];
                  };
                  extraSpecialArgs = {
                    hostname = "flurPC";
                    firefox-addons = inputs.firefox-addons;
                    secretsPath = nixos-secrets.secretsPath;
                    nixpkgs-unstable = import inputs.nixpkgs-unstable {
                      system = "x86_64-linux";
                      config.allowUnfree = true;
                    };
                    colors = colors;
                    oxicord = inputs.oxicord;
                  };
                  backupFileExtension = "backup";
                  sharedModules = [
                    inputs.zen-browser.homeModules.default
                    inputs.nixvim.homeModules.nixvim
                    inputs.nixcord.homeModules.nixcord
                    inputs.stylix.homeModules.stylix
                    sops-nix.homeManagerModules.sops
                  ];
                };
              }
            ];
            specialArgs = {
              secretsPath = nixos-secrets.secretsPath;
              colors = colors;
            };
          };
      };
    };
}
