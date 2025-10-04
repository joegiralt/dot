{ config, pkgs, opts, ... }:
{

  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports;
    [
      nextcloud-db
      nextcloud-http
      nextcloud-https
    ]
  );

  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/nextcloud        0755 ${opts.adminUID} ${opts.adminGID} -"
    "d ${opts.paths.app-data}/nextcloud/config 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d ${opts.paths.app-data}/nextcloud/data   0755 ${opts.adminUID} ${opts.adminGID} -"
    "d ${opts.paths.app-dbs}/nextcloud         0755 ${opts.adminUID} ${opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    nextcloud-db = {
      autoStart = true;
      image = "postgres:latest";
      volumes = [
        "${opts.paths.app-dbs}/nextcloud:/var/lib/postgresql/data"
      ];
      ports = [
        "${opts.ports.nextcloud-db}:5432"
      ];
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      environmentFiles = [ config.age.secrets.nextcloud-env.path ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };

    nextcloud = {
      autoStart = true;
      image = "lscr.io/linuxserver/nextcloud:latest";
      dependsOn = [ "nextcloud-db" ];
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      volumes = [
        "${opts.paths.app-data}/nextcloud/config:/config"
        "${opts.paths.app-data}/nextcloud/data:/data"
      ];
      ports = [
        "${opts.ports.nextcloud-http}:80"
        "${opts.ports.nextcloud-https}:443"
      ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
