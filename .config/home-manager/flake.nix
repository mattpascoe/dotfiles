# This file strictly manages standalone home stuff for now
{
  description = "Home Manager config for mdp";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

# For now, comment out darwin as I think this needs to live in .config/darwin separately
#    darwin = {
#      url = "github:lnl7/nix-darwin";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-darwin";

      mkHomeConfiguration = args: home-manager.lib.homeManagerConfiguration (rec {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./home.nix
          {
            home = {
              username = args.username;
              homeDirectory = args.homeDirectory;
              stateVersion = "23.05";
            };
          }
        ];
      } // args);

    in {
      # run with home-manager switch --flake .#mdp or similar
      homeConfigurations.mdp = mkHomeConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-darwin;
        modules = [
          ./home.nix
          {
            home = {
              username = "mdp";
              homeDirectory = "/Users/mdp";
              stateVersion = "23.05";
            };
          }
        ];
      };

      homeConfigurations.mdpextra = mkHomeConfiguration {
        extraSpecialArgs = {
          withGUI = true;
          isDesktop = true;
        };
      };
    };
}
