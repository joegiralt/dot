{
  pkgs,
  opts,
  ...
}:
{
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports; [ prowlarr ]
  );

  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/prowlarr 0755 ${opts.adminUID} ${opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    prowlarr = {
      autoStart = true;
      image = "ghcr.io/hotio/prowlarr";
      dependsOn = [ "flareSolverr" ];
      volumes = [
        "${opts.paths.app-data}/prowlarr:/config"
      ];
      ports = [ "${opts.ports.prowlarr}:9696" ];
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
