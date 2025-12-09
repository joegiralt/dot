{ ... }:
{
  imports = [
    ./adguard.nix
    ./oomd.nix
    ./tailscale.nix
    ./ailscale-health.nix
    ./vscode-server.nix
    ./unbound.nix
  ];
}
