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
  ];

  virtualisation = {
  containers.cdi.dynamic.nvidia.enable = true;
  podman = {
    enable = true;
    enableNvidia = true;
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
