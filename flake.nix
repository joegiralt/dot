{
  description = "Joe's Nix Flakes";

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
      nur,
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
            overlays = import ./common/overlays { inherit inputs; };
          };
          modules = [
            agenix.homeManagerModules.age
            # nur.repos.charmbracelet.modules.crush
            ./hosts/${host}/users/${username}
          ];
          extraSpecialArgs = {
            inherit
              inputs
              system
              username
              host
              ;
            opts =
              opts // (import ./hosts/${host}/opts.nix) // (import ./hosts/${host}/users/${username}/opts.nix);
          };
        };

      mkHomes =
        list:
        builtins.listToAttrs (
          map (x: {
            name = "${x.user}@${x.host}";
            value = mkHome x.system x.user x.host;
          }) list
        );

      mkSystems =
        list:
        builtins.listToAttrs (
          map (x: {
            name = x.host;
            value = mkSystem x.system x.host;
          }) list
        );
    in
    {
      # Formatters for all systems
      formatter = mkFormatters systems;

      # NixOS Configurations
      nixosConfigurations = mkSystems [
        {
          host = "athena0";
          system = systems.x86;
        }
        {
          host = "pop-os";
          system = systems.x86;
        }
      ];

      # HomeManager Configurations
      homeConfigurations = mkHomes [
        {
          user = "admin";
          host = "athena0";
          system = systems.x86;
        }
        {
          user = "carcosa";
          host = "pop-os";
          system = systems.x86;
        }
      ];
    };
}
