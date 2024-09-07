{ config, lib, pkgs, opts, ... }: {
  networking.firewall.allowedTCPPorts =
    builtins.map pkgs.lib.strings.toInt (
      with opts.ports; [
        uptime-kuma
      ]
    );

  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/uptime-kuma/ 0755 ${opts.adminUID} ${opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    # service Health Monitoring
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
      ports = [ "${opts.ports.uptime-kuma}:3001" ];
      labels = {
        "kuma.uptime-kuma.http.name" = "Uptime Kuma";
        "kuma.uptime-kuma.http.url" = "http://${opts.lanAddress}:${opts.ports.uptime-kuma}";
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
        AUTOKUMA__KUMA__URL = "http://${opts.hostname}:${opts.ports.uptime-kuma}";
      };
    };
  };
}
