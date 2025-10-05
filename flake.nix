{
  description = "Joe's Nix Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable&shallow=1";
    colmena.url = "github:zhaofengli/colmena";

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
    { self, ... }@inputs:
    let
      opts = import ./opts.nix;
      systems = {
        x86 = "x86_64-linux";
        arm64 = "aarch64-linux";
      };

      inherit (import ./lib { inherit inputs opts systems; })
        mkSystems
        mkHomes
        mkFormatters
        mkColmenaFromNixOSConfigurations
        forEachSystem
        ;
    in
    {

      # colmena deployments
      colmenaHive = mkColmenaFromNixOSConfigurations self.nixosConfigurations;

      # Formatters for all systems
      formatter = mkFormatters systems;

      checks = forEachSystem (pkgs: {
        lint =
          pkgs.runCommand "nixlint"
            {
              nativeBuildInputs = with pkgs; [
                deadnix
                statix
              ];
            }
            ''
              deadnix --fail ${./.}
              statix check ${./.}
              touch $out
            '';
      });

      # NixOS Configurations
      nixosConfigurations = mkSystems [
        {
          host = "athena0";
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
