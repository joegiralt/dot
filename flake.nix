{
  description = "A very basic flake (NixOS 25.05)";

  inputs = {
    # Track the 25.05 release branch (stable)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05?shallow=1";

    # Keep Home Manager in lockstep with the OS release
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # If you want select bleeding-edge packages while staying on stable OS,
    # uncomment this and import from `unstable` where needed.
    # unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable?shallow=1";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    agenix,
    # unstable,  # uncomment if using the optional input above
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
        {}
        (nixpkgs.lib.attrValues systemsl);

    mkSystem = pkgs: system: hostname:
      pkgs.lib.nixosSystem {
        system = system;
        modules = [
          (import ./hosts/${hostname}/configuration.nix)
          agenix.nixosModules.default
          # If mixing stable base with select unstable pkgs, you can pass them via specialArgs:
          # { _module.args.unstable = import inputs.unstable { inherit system; }; }
        ];
        specialArgs = {
          inherit system hostname inputs;
          opts = opts // (import ./hosts/${hostname}/opts.nix);
          # unstable = import inputs.unstable { inherit system; }; # if using unstable
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
