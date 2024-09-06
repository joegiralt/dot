{ config, lib, pkgs, opts, ... }: {
  networking.firewall.allowedTCPPorts = [ 9011 ];

  systemd.tmpfiles.rules = [
    "d /mnt/data/appdata/uptime-kuma/ 0755 ${opts.adminUID} ${opts.adminGID} -"
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
        "/mnt/data/appdata/uptime-kuma/:/app/data"
      ];
      ports = [ "9011:3001" ];
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
        "/var/run/podman/podman.sock:/var/run/docker.sock"
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
