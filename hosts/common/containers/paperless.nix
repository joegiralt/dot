{ pkgs, opts, config, ... }:
{
  networking.firewall.allowedTCPPorts = [ 9000 3306 6379 ];
  virtualisation.oci-containers.containers = {
    paperless-app = {
      autoStart = true;
      image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
      extraOptions = [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" ];
      dependsOn = [ "paperless-db" "paperless-redis" ];
      volumes = [
        "/mnt/data/appdata/paperless/consume:/usr/src/paperless/consume"
        "/mnt/data/appdata/paperless/data:/usr/src/paperless/data"
        "/mnt/data/appdata/paperless/export:/usr/src/paperless/export"
        "/mnt/data/appdata/paperless/media:/usr/src/paperless/media"
      ];
      ports = [ "9000:8000" ];
      environmentFiles = [ config.age.secrets.paperless-env.path ];
      environment = {
        PAPERLESS_REDIS = "redis://${opts.hostname}:6379";
        PAPERLESS_DBENGINE = "mariadb";
        PAPERLESS_DBHOST = "${opts.hostname}";
        PAPERLESS_DBUSER = "paperless";
        PAPERLESS_TIME_ZONE = opts.timeZone;
        PAPERLESS_OCR_LANGUAGE = "eng";
        PAPERLESS_DBPORT = "3306";
        PAPERLESS_URL = "https://paperless.nothing.ltd";
        USERMAP_UID = opts.adminUID;
        USERMAP_GID = opts.adminGID;
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };

    paperless-db = {
      autoStart = true;
      image = "docker.io/library/mariadb:11";
      volumes = [ "/mnt/data/databases/paperless:/var/lib/mysql" ];
      extraOptions = [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" ];
      ports = [ "3306:3306" ];
      environmentFiles = [ config.age.secrets.paperless-env.path ];
      environment = {
        MARIADB_HOST = "${opts.hostname}";
        MARIADB_DATABASE = "paperless";
        MARIADB_USER = "paperless";
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };

    paperless-redis = {
      autoStart = true;
      image = "docker.io/library/redis:7";
      extraOptions = [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" ];
      ports = [ "6379:6379" ];
      volumes = [
        "/mnt/data/databases/paperless/redis:/data"
      ];
    };
  };
}