{ inputs
, opts
, systems
, ...
}:
let
  inherit (inputs) nixpkgs agenix stylix home-manager colmena system-manager;
in
rec {
  pkgsFor = nixpkgs.legacyPackages;
  forEachSystem = f: nixpkgs.lib.genAttrs (builtins.attrValues systems) (sys: f pkgsFor.${sys});

  recurmerge =
    attrsets: nixpkgs.lib.fold (attrset: acc: nixpkgs.lib.recursiveUpdate attrset acc) { } attrsets;

  mkColmenaFromNixOSConfigurations =
    conf:
    colmena.lib.makeHive (
      {
        meta = {
          description = "Home Server Deployments";
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = import ../common/overlays { inherit inputs; };
          };
          nodeNixpkgs = builtins.mapAttrs (_: value: value.pkgs) conf;
          nodeSpecialArgs = builtins.mapAttrs (_: value: value._module.specialArgs) conf;
        };
      }
      // builtins.mapAttrs (_: value: { imports = value._module.args.modules; }) conf
    );

  mkFormatters =
    systemsl:
    builtins.foldl' (
      output: sys: output // { ${sys} = nixpkgs.legacyPackages."${sys}".nixfmt-tree; }
    ) { } (nixpkgs.lib.attrValues systemsl);

  mkSystem =
    system: hostname:
    nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        ../hosts/${hostname}/configuration.nix
      ];

      specialArgs = {
        inherit system inputs;
        opts = recurmerge [
          opts (import ../hosts/${hostname}/opts.nix)
        ];
      };
    };

  mkArchSystem =
    system: hostname:
    system-manager.lib.makeSystemConfig {
      modules = [
        ../hosts/${hostname}/configuration.nix
      ];
      extraSpecialArgs = {
        inherit system;
        opts = recurmerge [
          opts (import ../hosts/${hostname}/opts.nix)
        ];
      };
    };

  mkHome =
    system: username: host:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        overlays = import ../common/overlays { inherit inputs; };
      };

      modules = [
        ../hosts/${host}/users/${username}
        agenix.homeManagerModules.age
        stylix.homeModules.stylix
      ];

      extraSpecialArgs = {
        inherit
          system
          username
          host
          inputs
          ;
        opts = recurmerge [
          opts
          (import ../hosts/${host}/opts.nix)
          (import ../hosts/${host}/users/${username}/opts.nix)
        ];
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

  mkArchSystems =
    list:
    builtins.listToAttrs (
      map (x: {
        name = x.host;
        value = mkArchSystem x.system x.host;
      }) list
    );
}
