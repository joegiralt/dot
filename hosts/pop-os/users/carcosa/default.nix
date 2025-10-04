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
      trusted-users = [ "carcosa" ];
      http2 = false;
      allowed-users = [ "carcosa" ];
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

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
}
