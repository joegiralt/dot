{
  pkgs,
  opts,
  config,
  ...
}: {
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports; [
      paperless-app
      paperless-web
      paperless-redis
    ]
  );
  virtualisation.oci-containers.containers = {
    paperless-app = {
      autoStart = true;
      image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      dependsOn = [
        "paperless-db"
        "paperless-redis"
      ];
      volumes = [
        "${opts.paths.app-data}/paperless/consume:/usr/src/paperless/consume"
        "${opts.paths.app-data}/paperless/data:/usr/src/paperless/data"
        "${opts.paths.app-data}/paperless/export:/usr/src/paperless/export"
        "${opts.paths.app-data}/paperless/media:/usr/src/paperless/media"
      ];
      ports = ["${opts.ports.paperless-app}:8000"];
      labels = {
        "kuma.paperless-app.http.name" = "Paperless App";
        "kuma.paperless-app.http.url" = "http://${opts.lanAddress}:${opts.ports.paperless-app}";
      };
      environmentFiles = [
        config.age.secrets.paperless-env.path
      ];
      environment = {
        PAPERLESS_REDIS = "redis://${opts.hostname}:${opts.ports.paperless-redis}";
        PAPERLESS_DBENGINE = "mariadb";
        PAPERLESS_DBHOST = opts.hostname;
        PAPERLESS_DBUSER = "paperless";
        PAPERLESS_TIME_ZONE = opts.timeZone;
        PAPERLESS_OCR_LANGUAGE = "eng";
        PAPERLESS_DBPORT = opts.ports.paperless-db;
        PAPERLESS_URL = "https://paperless.${opts.publicURL}";
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
      volumes = ["${opts.paths.dbs}/paperless:/var/lib/mysql"];
      extraOptions = ["--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck"];
      ports = ["${opts.ports.paperless-db}:3306"];
      environmentFiles = [config.age.secrets.paperless-env.path];
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
      ports = ["${opts.ports.paperless-redis}:6379"];
      labels = {
        "kuma.paperless-redis.redis.name" = "Paperless Redis";
        "kuma.paperless-redis.redis.database_connection_string" = "redis://${opts.lanAddress}:${opts.ports.paperless-redis}";
      };
      volumes = [
        "${opts.paths.dbs}/paperless/redis:/data"
      ];
    };
  };
}
