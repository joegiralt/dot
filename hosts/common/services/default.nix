{pkgs, ...}: {
  imports = [
    ./adguard.nix
    # ./nvidia-cdi-setup.nix
    ./tailscale.nix
    ./vscode-server.nix
  ];
}
