{pkgs, ...}: {
  imports = [
    ./adguard.nix
    ./tailscale.nix
    ./vscode-server.nix
  ];
}
