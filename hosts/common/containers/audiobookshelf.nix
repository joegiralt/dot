{ config, lib, pkgs, opts, ... }: {
  networking.firewall.allowedTCPPorts = opts.portsToInts (with opts.ports; [ audiobookshelf ]);

  systemd.tmpfiles.rules =
    let
      paths = opts.paths;
      admin = opts;
    in
    [
      "d ${paths.audiobooks} 0755 ${admin.adminUID} ${admin.adminGID} -"
      "d ${paths.podcasts} 0755 ${admin.adminUID} ${admin.adminGID} -"
      "d ${paths.app-data}/audiobookshelf/metadata 0755 ${admin.adminUID} ${admin.adminGID} -"
      "d ${paths.app-data}/audiobookshelf/config 0755 ${admin.adminUID} ${admin.adminGID} -"
    ];

  virtualisation.oci-containers.containers = {
    audiobookshelf =
      let
        admin = opts;
        paths = opts.paths;
        ports = opts.ports;
        lanAddress = opts.lanAddress;
        timeZone = opts.timeZone;
        adminUID = opts.adminUID;
        adminGID = opts.adminGID;
      in
      {
        autoStart = true;
        image = "ghcr.io/advplyr/audiobookshelf:latest";
        extraOptions = [
          "--no-healthcheck"
        ];
        volumes = [
          "${paths.audiobooks}:/audiobooks"
          "${paths.podcasts}:/podcasts"
          "${paths.app-data}/audiobookshelf/metadata:/metadata"
          "${paths.app-data}/audiobookshelf/config:/config"
        ];
        ports = [ "${ports.audiobookshelf}:80" ];
        labels = {
          "kuma.audiobookshelf.http.name" = "Audiobookshelf";
          "kuma.audiobookshelf.http.url" = "http://${lanAddress}:${ports.audiobookshelf}/healthcheck";
        };
        environment = {
          TZ = timeZone;
          PUID = adminUID;
          PGID = adminGID;
        };
      };
  };
}
