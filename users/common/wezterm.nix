{
  inputs,
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

    package = gl inputs.wezterm.packages.${pkgs.system}.default;

    extraConfig = ''
      return {
        front_end = "WebGpu",
      }
    '';
  };
}
