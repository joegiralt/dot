{ pkgs, ... }:
{
  imports = [
    ./flaresolverr.nix
    ./homer.nix
    ./jackett.nix
    ./jellyfin.nix
    ./nginx-proxy-manager.nix
    ./ollama.nix
    ./paperless.nix
    ./stirling-pdf.nix
    ./telemetry.nix
    ./qbittorrent.nix
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = false;
    autoPrune.enable = true;
  };

  environment.systemPackages = with pkgs; [
    dive
    podman-tui
    podman-compose
  ];

}
