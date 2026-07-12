{
  description = "nixos for flur";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    fluxer.url = "github:flurbudurbur/fluxer-releases";
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
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    elephant.url = "github:abenz1267/elephant";
    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };
    nixos-secrets = {
      url = "git+ssh://git@github.com/flurbudurbur/nix-secrets?shallow=1&ref=main";
      flake = true;
    };
    tinted-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      # needs wlroots_0_20, not in stable 26.05
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      stylix,
      sops-nix,
      nixos-secrets,
      git-hooks,
      disko,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      overlays = import ./overlays { inherit inputs; };
    in
    {
      formatter.${system} = pkgs.nixfmt-tree;

      checks.${system}.pre-commit-check = git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt.enable = true;
          statix.enable = true;
          deadnix = {
            enable = true;
            excludes = [ "hardware-configuration\\.nix" ];
          };
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
      };
      nixosConfigurations = {
        flurPC =
          let
            username = "flur";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./hosts/flurPC
              stylix.nixosModules.stylix
              sops-nix.nixosModules.sops
              inputs.noctalia-greeter.nixosModules.default
              # Stylix/home-manager issue
              # Follow issues:
              # - https://github.com/nix-community/home-manager/pull/6172
              # - https://github.com/nix-community/stylix/issues/865
              {
                nixpkgs.overlays = overlays.all;
              }
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${username} = {
                    imports = [
                      ./users/${username}/desktop/home.nix
                    ];
                  };
                  extraSpecialArgs = {
                    hostname = "flurPC";
                    inherit (inputs) firefox-addons;
                    inherit (nixos-secrets) secretsPath;
                    inherit (inputs) tinted-schemes;
                    nixpkgs-unstable = import inputs.nixpkgs-unstable {
                      system = "x86_64-linux";
                      # claude-code is the only unfree package pulled from unstable
                      config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "claude-code" ];
                    };
                    inherit inputs;
                  };
                  backupFileExtension = "backup";
                  sharedModules = [
                    inputs.zen-browser.homeModules.default
                    inputs.nixvim.homeModules.nixvim
                    inputs.stylix.homeModules.stylix
                    sops-nix.homeManagerModules.sops
                    inputs.nix-flatpak.homeManagerModules.nix-flatpak
                    inputs.walker.homeManagerModules.default
                    inputs.nix-index-database.homeModules.nix-index
                  ];
                };
              }
            ];
            specialArgs = {
              inherit (nixos-secrets) secretsPath;
              inherit (inputs) tinted-schemes;
              inherit inputs;
            };
          };

        # Installer ISO with SSH key baked in, for headless nixos-anywhere
        # provisioning: nix build .#nixosConfigurations.installer.config.system.build.isoImage
        installer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            {
              users.users.root.openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMwJBOgc5FkuGdI7ywT+vf79pX4iSl+1nTOkk/klUixb flur@flurPC"
              ];
              isoImage.squashfsCompression = "zstd -Xcompression-level 3";
            }
          ];
        };

        flurLab =
          let
            username = "flur";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./hosts/flurLab
              disko.nixosModules.disko
              sops-nix.nixosModules.sops
              {
                nixpkgs.overlays = overlays.minimal;
              }
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${username} = {
                    imports = [
                      ./users/${username}/vps/home.nix
                    ];
                  };
                  extraSpecialArgs = {
                    inherit (nixos-secrets) secretsPath;
                    inherit inputs;
                  };
                  backupFileExtension = "backup";
                };
              }
            ];
            specialArgs = {
              inherit (nixos-secrets) secretsPath;
            };
          };

        vps =
          let
            username = "flur";
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./hosts/vps
              disko.nixosModules.disko
              sops-nix.nixosModules.sops
              {
                nixpkgs.overlays = overlays.minimal;
              }
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${username} = {
                    imports = [
                      ./users/${username}/vps/home.nix
                    ];
                  };
                  extraSpecialArgs = {
                    inherit (nixos-secrets) secretsPath;
                    inherit inputs;
                  };
                  backupFileExtension = "backup";
                };
              }
            ];
            specialArgs = {
              inherit (nixos-secrets) secretsPath;
            };
          };
      };
    };
}
