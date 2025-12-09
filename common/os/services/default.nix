{ ... }:
{
  imports = [
    ./adguard.nix
    ./oomd.nix
    ./tailscale.nix
    ./ailscale-auto-health.nix
    ./vscode-server.nix
    ./unbound.nix
  ];
}
