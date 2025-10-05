{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../../../../common/hm/base.nix
    ../../../../common/hm/core-max.nix
    ../../../../common/hm/fastfetch.nix
    ../../../../common/hm/firefox
    ../../../../common/hm/keybase.nix
    ../../../../common/hm/mise.nix
    ../../../../common/hm/wezterm.nix
    ../../../../common/hm/zathura.nix
  ];

  nixGL = {
    packages = pkgs.nixgl;
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
      ai-coding-agent-packages = with pkgs; [
        goose-cli
        nur.repos.charmbracelet.crush
      ];

      cli-packages = with pkgs; [
        agenix
        tokei
        colmena
      ];

      gui-packages = [
        (config.lib.nixGL.wrap pkgs.slack)
        (config.lib.nixGL.wrap pkgs.zed-editor)
        (config.lib.nixGL.wrapOffload pkgs.upscayl)
      ];

    in
    builtins.concatLists [
      ai-coding-agent-packages
      cli-packages
      gui-packages
    ];

  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraOptionOverrides = {
      StrictHostKeyChecking = "no";
      LogLevel = "ERROR";
    };
    matchBlocks = {
      "*" = {
        userKnownHostsFile = "/dev/null";
      };
    };
  };

  nix = {
    package = pkgs.nixVersions.nix_2_28;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      allowed-users = [ "carcosa" ];
      trusted-users = [ "carcosa" ];

      http2 = false;
      show-trace = true;
      auto-optimise-store = true;

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cuda-maintainers.cachix.org"
      ];

      trusted-public-keys = [
        # Official Nix cache
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        # nix-community (Cachix)
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        # cuda-maintainers (Cachix)
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];

      builders-use-substitutes = true;
      fallback = true;

      experimental-features = [
        "nix-command"
        "flakes"
        "recursive-nix"
      ];

      # optional QoL
      log-lines = 50;
      keep-outputs = true;
      keep-derivations = true;
    };
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

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
}
