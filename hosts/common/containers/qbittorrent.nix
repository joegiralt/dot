{ config, lib, pkgs, opts, ... }:
let
  vuetorrentSrc = builtins.fetchGit {
    name = "vuetorrent";
    url = "https://github.com/VueTorrent/VueTorrent";
    rev = "7aae128a7a439723c2e728cc5005510f1f5c72ce";
    ref = "latest-release";
    shallow = true;
  };
in
{

  environment.etc = {
    "vuetorrent" = {
      enable = true;
      source = vuetorrentSrc;
    };
  };

  networking.firewall.allowedTCPPorts = [
    6881
    8001
  ];

  networking.firewall.allowedUDPPorts = [ 6881 ];

  virtualisation.oci-containers.containers = {
    # qBittorrent P2P Torrent Client
    "qbittorrent-nox" = {
      autoStart = true;
      image = "qbittorrentofficial/qbittorrent-nox:latest";
      # ports = [
      #   "6881:6881/tcp"
      #   "6881:6881/udp"
      #   "8001:8001/tcp"
      # ];
      labels = {
        "kuma.qbittorrent-nox.http.name" = "Qbittorrent";
        "kuma.qbittorrent-nox.http.url" = "http://${opts.lanAddress}:6881";
      };
      environment = {
        QBT_EULA = "accept";
        QBT_VERSION = "latest";
        QBT_WEBUI_PORT = "8001";
        TZ = opts.timeZone;
        USER_UID = opts.adminUID;
        USER_GID = opts.adminGID;
      };
      volumes = [
        "/mnt/data/appdata/qbittorrent/config/:/config"
        "/mnt/data/downloads:/downloads"
        "/mnt/data/torrents:/torrents"
        "/mnt/data/media/images:/images"
        "/mnt/data/media/film:/film"
        "/mnt/data/media/books:/books"
        "/mnt/data/media/magazines:/magazines"
        "/etc/vuetorrent:/vuetorrent:ro"
      ];
      extraOptions = [
        "--network=host"
        "--no-healthcheck"
        "--memory=8g"
        "--memory-swap=16g"
        "--cpus=4"
        "--read-only"
        "--stop-timeout=1800"
        "--tmpfs=/tmp"
      ];
    };
  };
}









