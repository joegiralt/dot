{
  description = "A very basic flake (NixOS 25.05)";

  inputs = {
    # Track the 25.05 release branch (stable)
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable&shallow=1";
    unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable&shallow=1";

    # Keep Home Manager in lockstep with the OS release
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , agenix
    , # unstable,  # uncomment if using the optional input above
      ...
    } @ inputs:
    let
      opts = import ./opts.nix;

      systems = {
        x86 = "x86_64-linux";
        arm64 = "aarch64-linux";
      };

      mkFormatters = systemsl:
        builtins.foldl'
          (output: sys: output // { ${sys} = nixpkgs.legacyPackages."${sys}".nixpkgs-fmt; })
          { }
          (nixpkgs.lib.attrValues systemsl);

      mkSystem = pkgs: system: hostname:
        pkgs.lib.nixosSystem {
          system = system;
          modules = [
            # expose an `unstable` pkgs set to all modules as an argument
            {
              _module.args = {
                unstable = import inputs.unstable { inherit system; };
              };
            }
            agenix.nixosModules.default
            (import ./hosts/${hostname}/configuration.nix)
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
            opts =
              opts
              // (import ./hosts/${host}/opts.nix)
              // (import ./users/${username}/opts.nix);
            # unstable = import inputs.unstable { inherit system; }; # if using unstable
          };
        };
    in
    {
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
