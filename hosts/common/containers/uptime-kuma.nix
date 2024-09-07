{ config, lib, pkgs, opts, ... }: {
  networking.firewall.allowedTCPPorts = [ 9011 ];

  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/uptime-kuma/ 0755 ${opts.adminUID} ${opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    # Service Health Monitoring
    "uptime-kuma" = {
      autoStart = true;
      image = "louislam/uptime-kuma:1";
      extraOptions =
        [
          "--add-host=${opts.hostname}:${opts.lanAddress}"
          "--no-healthcheck"
        ];
      volumes = [
        "${opts.paths.app-data}/uptime-kuma/:/app/data"
      ];
      ports = [ "9011:3001" ];
      labels = {
        "kuma.uptime-kuma.http.name" = "Uptime Kuma";
        "kuma.uptime-kuma.http.url" = "http://${opts.lanAddress}:9011";
      };
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };

    "autokuma" = {
      autoStart = true;
      image = "ghcr.io/bigboot/autokuma:latest";
      dependsOn = [ "uptime-kuma" ];
      extraOptions = [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" ];
      volumes = [
        "${opts.paths.podman-socket}:/var/run/docker.sock"
      ];
      environmentFiles = [
        config.age.secrets.autokuma-env.path
      ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
        AUTOKUMA__KUMA__URL = "http://${opts.hostname}:9011";
      };
    };
  };
}
