{ config, lib, pkgs, opts, ... }: {
  networking.firewall.allowedTCPPorts =
    builtins.map pkgs.lib.strings.toInt (
      with opts.ports; [
        plex
      ]
    );

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
        "${opts.paths.film}:/movies"
        "${opts.paths.tv}:/tv"
      ];
      # ports = [ "${opts.paths.plex}:32400" ];
      labels = {
        "kuma.plex.http.name" = "Plex";
        "kuma.plex.http.url" = "http://${opts.lanAddress}:${opts.ports.plex}/identity";
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
