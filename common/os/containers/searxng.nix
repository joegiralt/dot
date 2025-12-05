{ pkgs, opts, ... }:
{

  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports; [ searxng-www ]
  );

  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/searxng 0755 ${opts.adminUID} ${opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    "searxng" = {
      autoStart = true;
      image = "searxng/searxng:latest";
      ports = [ "${opts.ports.searxng-www}:8080" ];
      volumes = [
        "${opts.paths.app-data}/searxng:/etc/searxng:rw"
      ];
      labels = {
        "com.centurylinklabs.watchtower.enable" = "true";
      };
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
        "--dns=${opts.lanAddress}"
      ];
      environment = {
        SEARXNG_BASE_URL = "https://searxng.nullptr.sh";
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
