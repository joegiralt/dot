{ config, lib, pkgs, opts, ... }: {
  networking.firewall.allowedTCPPorts = [ 8096 ];
  networking.firewall.allowedUDPPorts = [ 8096 ];

  virtualisation.oci-containers.containers = {
    "jellyfin" = {
      autoStart = true;
      image = "jellyfin/jellyfin";
      volumes = [
        "/mnt/data/appdata/jellyfin/config:/config"
        "/mnt/data/appdata/jellyfin/cache/:/cache"
        "/mnt/data/appdata/jellyfin/log/:/log"
        "/mnt/data/media/film:/film"
        "/mnt/data/media/tv:/tv"

      ];
      extraOptions =
        [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" ];
      ports = [ "8096:8096" ];
      labels = {
        "kuma.jellyfin.http.name" = "Jellyfin";
        "kuma.jellyfin.http.url" = "http://${opts.lanAddress}:8016";
      };
      environment = {
        JELLYFIN_LOG_DIR = "/log";
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
