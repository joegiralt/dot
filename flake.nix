{
  description = "A very basic flake (NixOS 25.05)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable&shallow=1";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:sreedevk/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wezterm = {
      url = "github:wezterm/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      agenix,
      ...
    }@inputs:
    let
      opts = import ./opts.nix;

      systems = {
        x86 = "x86_64-linux";
        arm64 = "aarch64-linux";
      };

      mkFormatters =
        systemsl:
        builtins.foldl' (
          output: sys: output // { ${sys} = nixpkgs.legacyPackages."${sys}".nixfmt-tree; }
        ) { } (nixpkgs.lib.attrValues systemsl);

      mkSystem =
        system: hostname:
        nixpkgs.lib.nixosSystem {
          system = system;
          modules = [
            agenix.nixosModules.default
            (import ./hosts/${hostname}/configuration.nix)
          ];
          specialArgs = {
            inherit system hostname inputs;
            opts = opts // (import ./hosts/${hostname}/opts.nix);
          };
        };

      mkHome =
        system: username: host:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            overlays = import ./users/overlays { inherit inputs; };
          };
          modules = [
            agenix.homeManagerModules.age
            ./users/${username}
          ];
          extraSpecialArgs = {
            inherit
              inputs
              system
              username
              host
              ;
            opts = opts // (import ./hosts/${host}/opts.nix) // (import ./users/${username}/opts.nix);
          };
        };
    in
    {
      # Formatters for all systems
      formatter = mkFormatters systems;

      # NixOS Configurations
      nixosConfigurations = {
        athena0 = mkSystem systems.x86 "athena0";
        pop-os = mkSystem systems.x86 "pop-os";
      };

      # HomeManager Configurations
      homeConfigurations = {
        admin = mkHome systems.x86 "admin" "athena0";
        carcosa = mkHome systems.x86 "carcosa" "pop-os";
      };
    };
}
