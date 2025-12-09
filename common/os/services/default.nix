{ ... }:
{
  imports = [
    ./adguard.nix
    ./oomd.nix
    ./tailscale.nix
    ./tailscale-auto-health.nix
    ./vscode-server.nix
    ./unbound.nix
  ];
}
