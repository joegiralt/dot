{ config, lib, pkgs, opts, ... }: {
  networking.firewall.allowedTCPPorts = [ 8096 ];
  networking.firewall.allowedUDPPorts = [ 8096 ];

  virtualisation.oci-containers.containers = {
    "jellyfin" = {
      autoStart = true;
      image = "jellyfin/jellyfin";
      volumes = [
        # APPLICATION DATA
        "/mnt/data/appdata/jellyfin/config:/config"
        "/mnt/data/appdata/jellyfin/cache:/cache"
        "/mnt/data/appdata/jellyfin/log:/log"
        # MEDIA
        "/mnt/data/media/movies:/movies"
        "/mnt/data/media/television:/television"
        "/mnt/data/media/audiobooks:/audiobooks"
        "/mnt/data/media/music:/music"
      ];
      extraOptions =
        [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" ];
      ports = [ "8096:8096" ];
      environment = {
        JELLYFIN_LOG_DIR = "/log";
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
