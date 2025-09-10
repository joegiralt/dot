{
  pkgs,
  opts,
  ...
}:
{
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports;
    [
      radarr
    ]
  );

  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/radarr   0755 ${opts.adminUID} ${opts.adminGID} -"
    "d ${opts.paths.film}              0755 ${opts.adminUID} ${opts.adminGID} -"
    "d ${opts.paths.downloads}         0755 ${opts.adminUID} ${opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    radarr = {
      autoStart = true;
      image = "ghcr.io/hotio/radarr";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      volumes = [
        "${opts.paths.app-data}/radarr:/config"
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
