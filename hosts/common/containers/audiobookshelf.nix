{ config, lib, pkgs, opts, ... }: {
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (with opts.ports; [ audiobookshelf ]);

  with opts.paths; with opts; systemd.tmpfiles.rules = [
    "d ${audiobooks} 0755 ${adminUID} ${adminGID} -"
    "d ${podcasts} 0755 ${adminUID} ${adminGID} -"
    "d ${app-data}/audiobookshelf/metadata 0755 ${adminUID} ${adminGID} -"
    "d ${app-data}/audiobookshelf/config 0755 ${adminUID} ${adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    "audiobookshelf" = {
      autoStart = true;
      image = "ghcr.io/advplyr/audiobookshelf:latest";
      extraOptions = [
        "--no-healthcheck"
      ];
      with opts.paths; volumes = [
        "${audiobooks}:/audiobooks"
        "${podcasts}:/podcasts"
        "${app-data}/audiobookshelf/metadata:/metadata"
        "${app-data}/audiobookshelf/config:/config"
      ];
      ports = [ "13378:80" ];
      labels = {
        "kuma.audiobookshelf.http.name" = "Audiobookshelf";
        "kuma.audiobookshelf.http.url" = "http://${opts.lanAddress}:${opts.ports.audiobookshelf}/healthcheck";
      };
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
