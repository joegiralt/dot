{ ... }:
{
  imports = [
    ./adguard.nix
    ./attic.nix
    ./minecraft.nix
    ./oomd.nix
    ./tailscale.nix
    ./tailscale-auto-health.nix
    # ./vscode-server.nix
    ./unbound.nix
  ];
}
