{
  config,
  lib,
  pkgs,
  opts,
  ...
}:
{
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports; [ audiobookshelf ]
  );

  systemd.tmpfiles.rules = [
    "d ${opts.paths.audiobooks} 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d ${opts.paths.podcasts} 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d ${opts.paths.app-data}/audiobookshelf/metadata 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d ${opts.paths.app-data}/audiobookshelf/config 0755 ${opts.adminUID} ${opts.adminGID} -"
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
        "${opts.paths.audiobooks}:/audiobooks"
        "${opts.paths.podcasts}:/podcasts"
        "${opts.paths.app-data}/audiobookshelf/metadata:/metadata"
        "${opts.paths.app-data}/audiobookshelf/config:/config"
      ];
      ports = [ "${opts.ports.audiobookshelf}:80" ];
      labels = {
        "kuma.audiobookshelf.http.name" = "Audiobookshelf";
        "kuma.audiobookshelf.http.url" =
          "http://${opts.lanAddress}:${opts.ports.audiobookshelf}/healthcheck";
      };
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
