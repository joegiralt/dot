{
  pkgs,
  config,
  ...
}:

let
  gl = config.lib.nixGL.wrap;
in
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;

    package = gl pkgs.wezterm;

    extraConfig = ''
      return {
        front_end = "WebGpu",
      }
    '';
  };
}
