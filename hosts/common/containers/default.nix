{pkgs, ...}: {
  imports = [
    ./audiobookshelf.nix
    ./filebrowser.nix
    ./flaresolverr.nix
    ./homer.nix
    ./jackett.nix
    ./jellyfin.nix
    ./livebook.nix
    ./nginx-proxy-manager.nix
    ./ollama.nix
    ./paperless.nix
    ./plex.nix
    ./servarr.nix
    ./stirling-pdf.nix
    ./telemetry.nix
    ./qbittorrent.nix
    ./uptime-kuma.nix
    ./archive-warrior.nix
    ./portainer.nix
    ./romms.nix
  ];

  virtualisation = {
    containers.cdi.dynamic.nvidia.enable = true;
    podman = {
      enable = true;
      enableNvidia = true;
    };
  };

  environment.systemPackages = with pkgs; [
    dive
    podman-tui
    podman-compose
  ];
}
