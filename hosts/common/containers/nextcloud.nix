{
  config,
  pkgs,
  opts,
  ...
}:
{

networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
  with opts.ports;
  [
    nextcloud
    nextcloud-db
  ]
  );
  virtualisation.oci-containers.containers = {
    nextcloud-db = {
      autoStart = true;
      image = "postgres:latest";
      volumes = [ "/mnt/data/databases/nextcloud:/var/lib/postgresql/data" ];
      ports = [ "${opts.ports.nextcloud-db}:5432" ];
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
        "/mnt/data/appdata/nextcloud/config:/config"
        "/mnt/data/appdata/nextcloud/data:/data"
      ];
      ports = [
        "${opts.ports.nextcloud}:80"
      ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
