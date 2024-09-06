{ config, lib, pkgs, opts, ... }: {
  networking.firewall.allowedTCPPorts = [ 9002 ];
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
        "mnt/data/appdata/uptime-kuma/:/app/data"
      ];
      ports = [ "9002:3001" ];
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
        AUTOKUMA__KUMA__URL = "http://${opts.hostname}:${opts.ports.uptime-kuma}";
      };
    };
  };
}
