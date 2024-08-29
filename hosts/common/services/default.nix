{ pkgs, ... }:
{
  imports = [
    ./adguard.nix
    # ./mullvad.nix
    ./tailscale.nix
    ./vscode-server.nix
  ];
}
