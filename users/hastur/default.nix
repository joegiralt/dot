{ inputs, ... }:
{
  imports = [
    # ../common/atuin.nix
    ../common/base.nix
    # ../common/beets.nix
    # ../common/btop.nix
    # ../common/core-max.nix
    # ../common/git.nix
    # ../common/github.nix
    # ../common/vscode.nix
    # ../common/zsh.nix
  ];

  nixGL = {
    inherit (inputs.nixgl) packages;
    defaultWrapper = "mesa";
    offloadWrapper = "nvidia";
    vulkan.enable = true;
    installScripts = [
      "mesa"
      "nvidia"
    ];
  };
  
  home.packages =
    let
      gui-packages = with pkgs; [
        (config.lib.nixGL.wrap pkgs.slack)
        ];
      cli-packages = with pkgs; [
        agenix # age based nix secrets!
      ]
    in
    builtins.concatLists [
      gui-packages
      cli-packages
    ];
  };  
}
