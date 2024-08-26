{ pkgs, ... }:
{
  imports = [
    ./adguard.nix
    ./vscode-server.nix
  ];
}
