# This file strictly manages standalone home stuff for now
# My goal for now is just package management to replace brew
# With all the nix termoil and such, I'm not yet sold on doing everything
# here. While its compelling, I may not want to go all in?
# This means that nix will be mostly mac for the time being
# Another thing I dont like about NIX as a whole, when I try to have AI help out with
# config it is NEVER accurate. The DDL is not intuitive enough for general usage.
{
  description = "Home Manager config for mdp";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      # TODO: find a way to auto detect this
      system = "aarch64-darwin";

      mkHomeConfiguration = args: home-manager.lib.homeManagerConfiguration (rec {
        pkgs = nixpkgs.legacyPackages.${system};
        #        modules = [
        #          ./home.nix
        #          {
        #            home = {
        #              username = "someuser";
        #              homeDirectory = "/Users/someuser";
        #              # This value determines the Home Manager release that your configuration is
        #              # compatible with. This helps avoid breakage when a new Home Manager release
        #              # introduces backwards incompatible changes.
        #              #
        #              # You should not change this value, even if you update Home Manager. If you do
        #              # want to update the value, then make sure to first check the Home Manager
        #              # release notes.
        #              stateVersion = "23.05";
        #            };
        #          }
        #        ];
      } // args);

    in {

      # run with home-manager switch --flake .#mdp or similar
      homeConfigurations.mdp = mkHomeConfiguration {
        #pkgs = nixpkgs.legacyPackages.x86_64-darwin;
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

      homeConfigurations.mpascoe = mkHomeConfiguration {
        #pkgs = nixpkgs.legacyPackages.x86_64-darwin;
        modules = [
          ./home.nix
          {
            home = {
              username = "mpascoe";
              homeDirectory = "/Users/mpascoe";
              stateVersion = "23.05";
            };
          }
        ];
        extraSpecialArgs = {
          isWork = true;
        };
      };

    };
}
