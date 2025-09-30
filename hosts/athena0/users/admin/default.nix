{ inputs, username, pkgs, ... }:
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

  nix = {
    package = pkgs.nixVersions.nix_2_28;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      trusted-users = [ "${username}" ];
      http2 = false;
      allowed-users = [ "${username}" ];
      trusted-substituters = [ "https://cache.nixos.org/" ];
      substituters = [ "https://cache.nixos.org/" ];
      show-trace = true;
      auto-optimise-store = true;
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      fallback = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "recursive-nix"
      ];
    };
  };
}
