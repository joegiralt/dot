{ config, lib, pkgs, opts, ... }: {
  networking.firewall.allowedTCPPorts = [ 9009 ];

  systemd.tmpfiles.rules = [
    "d /mnt/data/appdata/plex/database 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d /mnt/data/appdata/plex/transcode 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d /mnt/data/media/music 0755 ${opts.adminUID} ${opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    "plex" = {
      autoStart = true;
      image = "plexinc/pms-docker";
      extraOptions = [ "--no-healthcheck" ];
      volumes = [
        "/mnt/data/appdata/plex/database/:/config"
        "/mnt/data/appdata/plex/transcode/:/transcode"
        "/mnt/data/media/music:/music"
      ];
      ports = [ "9009:32400" ];
      environmentFiles = [ config.age.secrets.plex-env.path ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
