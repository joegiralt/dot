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
    ../../../../common/hm/starship.nix
    ../../../../common/hm/zsh.nix
  ];

  targets.genericLinux.nixGL = {
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

      font-packages = with pkgs; [
        nerd-fonts.iosevka
        nerd-fonts.iosevka-term
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        nerd-fonts.hack
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
      font-packages
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
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://cuda-maintainers.cachix.org"
        "https://numtide.cachix.org"
        "https://colmena.cachix.org"
      ];

      trusted-substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://cuda-maintainers.cachix.org"
        "https://numtide.cachix.org"
        "https://colmena.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cuda-maintainers.cachix.org-1:Ji+ZysQ8GqEtvQF3o4O5q6c3y8C3b2q9p5g6s7d8e9k="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
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
