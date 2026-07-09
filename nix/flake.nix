{
  description = "Nixos config flake";

  nixConfig = {
    extra-substituters = [ "https://vicinae.cachix.org" ];
    extra-trusted-public-keys = [ "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-fonts = {
      url =  "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae.url = "github:vicinaehq/vicinae";

    # stylix = {
    #     url = "github:danth/stylix";
    #     inputs.nixpkgs.follows = "nixpkgs";
    #   };
  };

  outputs = { self, nixpkgs, vicinae, home-manager , nixpkgs-unstable, ... }@inputs:
  # use "nixos", or your hostname as the name of the configuration
  # it's a better practice than "default" shown in the video
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    unstable-pkgs = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in
    {

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs unstable-pkgs;};
          modules = [
            ./hosts/default/configuration.nix

            vicinae.nixosModules.default

            inputs.home-manager.nixosModules.home-manager {

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = {inherit inputs;};
              };
            }
          ];
        };
      };

      homeConfigurations."..." = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux"; # e.g. x86_64-linux
        modules = [vicinae.homeManagerModules.default];
      };

    };
  }
