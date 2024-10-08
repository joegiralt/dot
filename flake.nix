{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable&shallow=1";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    agenix,
    ...
  } @ inputs: let
    opts = import ./opts.nix;

    systems = {
      x86 = "x86_64-linux";
      arm64 = "aarch64-linux";
    };

    mkFormatters = systemsl:
      builtins.foldl'
      (output: sys: output // {${sys} = nixpkgs.legacyPackages."${sys}".nixpkgs-fmt;})
      {}
      (nixpkgs.lib.attrValues systemsl);

    mkSystem = pkgs: system: hostname:
      pkgs.lib.nixosSystem {
        system = system;
        modules = [
          (import ./hosts/${hostname}/configuration.nix)
          agenix.nixosModules.default
        ];
        specialArgs = {
          inherit system hostname inputs;
          opts = opts // (import ./hosts/${hostname}/opts.nix);
        };
      };

    mkHome = pkgs: system: username: host:
      home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs.legacyPackages."${system}";
        modules = [
          # stylix.homeManagerModules.stylix
          ./users/${username}
        ];
        extraSpecialArgs = {
          inherit system username host;
          opts = opts // (import ./hosts/${host}/opts.nix) // (import ./users/${username}/opts.nix);
        };
      };
  in {
    # Formatters for all systems
    formatter = mkFormatters systems;

    # NixOS Configurations
    nixosConfigurations = {
      athena0 = mkSystem nixpkgs systems.x86 "athena0";
    };

    # HomeManager Configurations
    homeConfigurations = {
      admin = mkHome nixpkgs systems.x86 "admin" "athena0";
    };
  };
}
