{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;
  programs.eza = {
    enable = true;
    icons = "auto";
  };
}
