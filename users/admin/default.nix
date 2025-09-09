{ inputs, ... }:
{
  imports = [
    ../common/atuin.nix
    ../common/base.nix
    ../common/btop.nix
    ../common/core-max.nix
    ../common/git.nix
    ../common/github.nix
    ../common/vscode.nix
    ../common/zsh.nix
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
}
