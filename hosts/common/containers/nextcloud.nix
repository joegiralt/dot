{ config, lib, pkgs, opts, ... }: {

  networking.firewall.allowedTCPPorts = [ 443 80 ];

  virtualisation.oci-containers.containers = {
    "nextcloud-db" = {
      autoStart = true;
      image = "postgres:latest";
      volumes = [ "/mnt/data/databases/nextcloud:/var/lib/postgresql/data" ];
      ports = [ "5432:5432" ];
      extraOptions =
        [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" ];
      environmentFiles = [ config.age.secrets.nextcloud-env.path ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };

    "nextcloud" = {
      autoStart = true;
      image = "lscr.io/linuxserver/nextcloud:latest";
      dependsOn = [ "nextcloud-db" ];
      extraOptions =
        [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" ];
      volumes = [
        "/mnt/data/appdata/nextcloud/config:/config"
        "/mnt/data/appdata/nextcloud/data:/data"
      ];
      ports = [ "444:443" "84:80" ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
