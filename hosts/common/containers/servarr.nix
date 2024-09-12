{
  config,
  lib,
  pkgs,
  opts,
  ...
}: {
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (with opts.ports; [
    prowlarr
    radarr
    # bazarr
    # lidarr
    # readarr
    # sonarr
  ]);

  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/prowlarr 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d ${opts.paths.app-data}/radarr 0755 ${opts.adminUID} ${opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    "prowlarr" = {
      autoStart = true;
      image = "ghcr.io/hotio/prowlarr";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      dependsOn = [
        "flareSolverr"
      ];
      volumes = [
        "${opts.paths.app-data}/prowlarr/:/config"
      ];
      ports = [
        "${opts.ports.prowlarr}:9696"
      ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };

    "radarr" = {
      autoStart = true;
      image = "ghcr.io/hotio/radarr";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      volumes = [
        "${opts.paths.app-data}/radarr/:/config"
        "${opts.paths.film}:/movies"
        "${opts.paths.downloads}:/downloads"
      ];
      ports = [
        "${opts.ports.radarr}:7878"
      ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
