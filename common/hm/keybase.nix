{
  pkgs,
  config,
  ...
}:
{

  home.packages = with pkgs; [
    keybase
    (config.lib.nixGL.wrap pkgs.keybase-gui)
  ];

  # ponytail: keybase-gui ships EOL Electron 28; permit it or drop the GUI
  nixpkgs.config.permittedInsecurePackages = [ "keybase-gui-6.5.1" ];

  services.keybase.enable = true;
  services.kbfs.enable = true;

}
