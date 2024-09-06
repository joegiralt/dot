{ config
, lib
, pkgs
, opts
, ...
}: {

  networking.firewall.allowedTCPPorts = [ 9008 ];

  systemd.tmpfiles.rules = [
    "d /mnt/data/appdata/filebrowser/ 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d /mnt/data/appdata/filebrowser/database 0755 ${opts.adminUID} ${opts.adminGID} -"
    "f /mnt/data/appdata/filebrowser/database/filebrowser.db 0644 ${opts.adminUID} ${opts.adminGID} -"
    "d /mnt/data/appdata/filebrowser/config 0755 ${opts.adminUID} ${opts.adminGID} -"
    "f /mnt/data/appdata/filebrowser/config/settings.json 0644 ${opts.adminUID} ${opts.adminGID} -"
  ];

  environment.etc."filebrowser/config/settings.json".text = ''
    {
      "port": 8080,
      "baseURL": "",
      "address": "",
      "log": "stdout",
      "database": "/database/filebrowser.db",
      "root": "/srv"
    }
  '';

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
        "/mnt/data/appdata/filebrowser/database/filebrowser.db:/database/filebrowser.db"
        "/mnt/data/appdata/filebrowser/config/settings.json:/config/settings.json"
      ];
      ports = [ "9008:8080" ];
      labels = {
        "kuma.ntfy.http.name" = "Filebrowser";
        "kuma.ntfy.http.url" = "http://${opts.lanAddress}:9008";
      };
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
