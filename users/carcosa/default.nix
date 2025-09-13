{
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [
    ../common/base.nix
    ../common/mise.nix
    ../common/wezterm.nix
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
      # NOTE: nixGL.wrap is intel and nixGL.wrapOffload is nvidia
      #       I recommend choosing one or the other when install gui apps
      gui-packages = [
        (config.lib.nixGL.wrap pkgs.slack)
        (config.lib.nixGL.wrap pkgs.zed-editor)
      ];

      cli-packages = with pkgs; [
        tokei
        agenix
      ];
    in
    builtins.concatLists [
      gui-packages
      cli-packages
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
      # "github.com" = {
      #   hostname = "github.com";
      #   user = "git";
      #   identitiesOnly = true;
      #   identityFile = "~/.ssh/id_ed25519";
      # };
    };
  };
}
