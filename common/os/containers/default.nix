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
    ./jellyseer.nix
    ./kavita.nix
    ./lidarr.nix
    ./livebook.nix
    ./navidrome.nix
    ./nginx-proxy-manager.nix
    ./ollama.nix
    ./paperless.nix
    ./plex.nix
    ./portainer.nix
    ./prowlarr.nix
    ./qbittorrent.nix
    ./radarr.nix
    ./readarr.nix
    ./romms.nix
    ./searxng.nix
    ./sonarr.nix
    ./stirling-pdf.nix
    ./telemetry.nix
    ./uptime-kuma.nix
    ./woodpecker.nix
  ];

  hardware.nvidia-container-toolkit.enable = true;
  virtualisation = {
    podman = {
      enable = true;
    };
  };

  # Shared DNS-disabled podman network for service containers.
  # Prevents aardvark-dns from conflicting with AdGuard on port 53.
  # Containers on this network use explicit --dns flags for resolution.
  systemd.services.podman-network-services = {
    description = "Create DNS-disabled podman network for services";
    after = [ "podman.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.podman}/bin/podman network create --disable-dns --ignore services";
    };
  };

  environment.systemPackages = with pkgs; [
    dive
    podman-tui
    podman-compose
  ];
}
