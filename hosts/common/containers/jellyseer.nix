{ pkgs, opts, ... }:
{
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports; [ jellyseer ]
  );

  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/jellyseer 0755 ${opts.adminUID} ${opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    "jellyseer" = {
      autoStart = true;
      image = "fallenbagel/jellyseerr:latest";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      volumes = [ "${opts.paths.app-data}/jellyseer:/app/config" ];
      ports = [ "${opts.ports.jellyseer}:5055" ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
