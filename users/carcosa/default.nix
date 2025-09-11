{
  pkgs,
  config,
  inputs,
  ...
}:

let
  onlyIf = cond: xs: if cond then xs else [];
  gl     = pkg: config.lib.nixGL.wrap pkg;
  gloff  = pkg: config.lib.nixGL.wrapOffload pkg;
in
{
  imports = [
    ../common/base.nix
  ];

  nixGL = {
    inherit (inputs.nixgl) packages;
    defaultWrapper = "mesa";
    offloadWrapper = "nvidia";
    vulkan.enable = true;
    installScripts = [ "mesa" "nvidia" ];
  };

  home.packages =
    let
      gui-packages = builtins.concatLists [
        # Slack is x86_64-linux only; wrap with nixGL
        (onlyIf (pkgs.system == "x86_64-linux") [
          (gl pkgs.slack)
        ])
        
      ];

      cli-packages = with pkgs; [
        tokei
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
      "*" = { userKnownHostsFile = "/dev/null"; };
      # "github.com" = {
      #   hostname = "github.com";
      #   user = "git";
      #   identitiesOnly = true;
      #   identityFile = "~/.ssh/id_ed25519";
      # };
    };
  };
}
