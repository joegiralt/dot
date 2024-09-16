{pkgs, ...}: {
  imports = [
    ./adguard.nix
    ./nvidia-cdi-setup
    ./tailscale.nix
    ./vscode-server.nix
  ];
}
