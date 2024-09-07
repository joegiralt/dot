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
        "${opts.paths.app-data}/paperless/consume:/usr/src/paperless/consume"
        "${opts.paths.app-data}/paperless/data:/usr/src/paperless/data"
        "${opts.paths.app-data}/paperless/export:/usr/src/paperless/export"
        "${opts.paths.app-data}/paperless/media:/usr/src/paperless/media"
      ];
      ports = [ "9000:8000" ];
      labels = {
        "kuma.paperless-app.http.name" = "Paperless App";
        "kuma.paperless-app.http.url" = "http://${opts.lanAddress}:9000";
      };
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
      volumes = [ "${opts.paths.dbs}/paperless:/var/lib/mysql" ];
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
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      ports = [ "6379:6379" ];
      labels = {
        "kuma.paperless-redis.redis.name" = "Paperless Redis";
        "kuma.paperless-redis.redis.database_connection_string" = "redis://${opts.lanAddress}:6379";
      };
      volumes = [
        "${opts.paths.dbs}/paperless/redis:/data"
      ];
    };
  };
}
