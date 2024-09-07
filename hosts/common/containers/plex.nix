{ config, lib, pkgs, opts, ... }: {
  networking.firewall.allowedTCPPorts = [ 32400 ];

  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/plex/database 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d ${opts.paths.app-data}/plex/transcode 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d ${opts.paths.music} 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d /mnt/data2/media/film 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d /mnt/data2/media/tv 0755 ${opts.adminUID} ${opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    "plex" = {
      autoStart = true;
      image = "plexinc/pms-docker";
      extraOptions = [
        "--no-healthcheck"
        "--network=host"
      ];
      volumes = [
        "${opts.paths.app-data}/plex/database/:/config"
        "${opts.paths.app-data}/plex/transcode/:/transcode"
        "${opts.paths.music}:/music"
        "/mnt/data2/media/film:/movies"
        "/mnt/data2/media/tv:/tv"
      ];
      # ports = [ "32400:32400" ];
      labels = {
        "kuma.plex.http.name" = "Plex";
        "kuma.plex.http.url" = "http://${opts.lanAddress}:32400/identity";
      };
      environmentFiles = [ config.age.secrets.plex-env.path ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
