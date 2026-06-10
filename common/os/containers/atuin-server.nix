{
  pkgs,
  opts,
  ...
}:
{

  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports; [ atuin-server ]
  );

  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-dbs}/atuin 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d ${opts.paths.app-data}/atuin 0755 ${opts.adminUID} ${opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    atuin-server = {
      autoStart = true;
      image = "ghcr.io/atuinsh/atuin:latest";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      volumes = [
        "${opts.paths.app-data}/atuin:/config"
      ];
      ports = [
        "${opts.ports.atuin-server}:8888"
      ];
      cmd = [
        "server"
        "start"
      ];
      dependsOn = [ "atuin-db" ];
      environmentFiles = [ ];
      environment = {
        ATUIN_HOST = "0.0.0.0";
        ATUIN_OPEN_REGISTRATION = "true";
        RUST_LOG = "info,atuin_server=debug";
        PGID = opts.adminGID;
        PUID = opts.adminUID;
        TZ = opts.timeZone;
        # FIX: PLEASE MOVE THIS TO AGENIX BEFORE AND SET VALUES BEFORE MERGING
        ATUIN_DB_URI = "postgres://$ATUIN_DB_USERNAME:$ATUIN_DB_PASSWORD@db/$ATUIN_DB_NAME";
      };
    };
    atuin-db = {
      autoStart = false;
      image = "postgres:14";
      volumes = [
        "${opts.paths.app-dbs}/atuin:/var/lib/postgresql/data/"
      ];
      environmentFiles = [ ];
      environment = {
        # FIX: PLEASE MOVE THIS TO AGENIX BEFORE AND SET VALUES BEFORE MERGING
        POSTGRES_USER = "\${ATUIN_DB_USERNAME}";
        POSTGRES_PASSWORD = "\${ATUIN_DB_PASSWORD}";
        POSTGRES_DB = "\${ATUIN_DB_NAME}";
        PGID = opts.adminGID;
        PUID = opts.adminUID;
        TZ = opts.timeZone;
      };
    };
  };
}
