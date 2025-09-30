{
  inputs,
  username,
  pkgs,
  ...
}:
{
  imports = [
    ../../../../common/hm/atuin.nix
    ../../../../common/hm/base.nix
    ../../../../common/hm/beets.nix
    ../../../../common/hm/btop.nix
    ../../../../common/hm/core-max.nix
    ../../../../common/hm/git.nix
    ../../../../common/hm/github.nix
    ../../../../common/hm/vscode.nix
    ../../../../common/hm/zsh.nix
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

  home.file = {
    ".config/nixpkgs/config.nix" = {
      enable = true;
      text = ''
        {
          allowUnfree = true;
          allowBroken = true;
          packageOverrides = pkgs: {
            nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz") {
              inherit pkgs;
            };
          };
        }
      '';
    };
  };
}
