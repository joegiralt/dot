{ config
, lib
, pkgs
, opts
, ...
}: {

  networking.firewall.allowedTCPPorts = [ 9009 ];

  systemd.tmpfiles.rules = [
    "d /mnt/data/appdata/filebrowser/database 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d /mnt/data/appdata/filebrowser/config 0755 ${opts.adminUID} ${opts.adminGID} -"

  ];

  virtualisation.oci-containers.containers = {
    "filebrowser" = {
      autoStart = true;
      image = "filebrowser/filebrowser:s6";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      volumes = [
        "/:/srv"
        "/mnt/data/appdata/filebrowser/database:/database/filebrowser.db"
        "/mnt/data/appdata/filebrowser/config:/config/settings.json"
      ];
      ports = [ "9009:80" ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
