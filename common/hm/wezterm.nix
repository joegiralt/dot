{ pkgs, config, ... }:
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    package = config.lib.nixGL.wrapOffload pkgs.wezterm;
    extraConfig = ''
      return {
        front_end = "WebGpu",
      }
    '';
  };
}
