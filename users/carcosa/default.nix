{ config, pkgs, inputs, ... }:

{
  # Make sure the nixGL HM module is imported so `config.lib.nixGL.wrap` exists.
  # If your nixgl input exposes a different name, try `.default` instead of `.nixGL`.
  imports = [
    inputs.nixgl.homeManagerModules.nixGL
    ../common/base.nix
    # ../common/atuin.nix
    # ../common/beets.nix
    # ../common/btop.nix
    # ../common/core-max.nix
    # ../common/git.nix
    # ../common/github.nix
    # ../common/vscode.nix
    # ../common/zsh.nix
  ];

  # nixGL configuration
  nixGL = {
    inherit (inputs.nixgl) packages;   # expects nixgl to be a flake input
    defaultWrapper = "mesa";           # AMD/Intel iGPU path
    offloadWrapper  = "nvidia";        # NVIDIA offload wrapper if needed
    vulkan.enable   = true;
    installScripts  = [ "mesa" "nvidia" ];
  };

  # Convenience alias
  # (only valid because the nixGL HM module is imported above)
  _module.args.wrapGL = config.lib.nixGL.wrap;

  home.packages =
    let
      # Helper: conditionally include packages
      onlyIf = cond: pkgsList: if cond then pkgsList else [];

      # Helper: wrap with nixGL on Linux GUI apps
      gl = pkg: config.lib.nixGL.wrap pkg;

      gui-packages =
        builtins.concatLists [
          # Slack is x86_64-linux only (Electron binary). Gate it.
          (onlyIf (pkgs.system == "x86_64-linux") [
            (gl pkgs.slack)
          ])
        ];

      cli-packages = with pkgs; [
        agenix
      ];
    in
      gui-packages ++ cli-packages;
}
