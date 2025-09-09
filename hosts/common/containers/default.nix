{ pkgs, ... }:
{
  imports = [
    ./archive-warrior.nix
    ./audiobookshelf.nix
    ./filebrowser.nix
    ./flaresolverr.nix
    ./homer.nix
    ./jackett.nix
    ./jellyfin.nix
    ./livebook.nix
    ./navidrome.nix
    ./nginx-proxy-manager.nix
    ./ollama.nix
    ./paperless.nix
    ./plex.nix
    ./portainer.nix
    ./qbittorrent.nix
    ./romms.nix
    ./servarr.nix
    ./stirling-pdf.nix
    ./telemetry.nix
    ./uptime-kuma.nix
  ];

  hardware.nvidia-container-toolkit.enable = true;
  virtualisation = {
    podman = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    dive
    podman-tui
    podman-compose
  ];
}
