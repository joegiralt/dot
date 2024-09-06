{ config, lib, pkgs, opts, ... }: {
  networking.firewall.allowedTCPPorts = [ 13378 ];

  systemd.tmpfiles.rules = [
    "d /mnt/data/media/audiobooks 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d /mnt/data/media/podcasts 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d /mnt/data/appdata/audiobookshelf/metadata 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d /mnt/data/appdata/audiobookshelf/config 0755 ${opts.adminUID} ${opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    "audiobookshelf" = {
      autoStart = true;
      image = "ghcr.io/advplyr/audiobookshelf:latest";
      extraOptions = [
        "--no-healthcheck"
        # "--network=host"
      ];
      volumes = [
        "/mnt/data/media/audiobooks:/audiobooks"
        "/mnt/data/media/podcasts:/podcasts"
        "/mnt/data/appdata/audiobookshelf/metadata:/metadata"
        "/mnt/data/appdata/audiobookshelf/config:/config"
      ];
      ports = [ "13378:80" ];
      labels = {
        "kuma.audiobookshelf.http.name" = "Audiobookshelf";
        "kuma.audiobookshelf.http.url" = "http://${opts.lanAddress}:13378/healthcheck";
      };
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
