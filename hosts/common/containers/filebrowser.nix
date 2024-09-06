{ config
, lib
, pkgs
, opts
, ...
}: {

  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (with opts.ports; [ filebrowser ]);

  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/filebrowser/ 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d ${opts.paths.app-data}/filebrowser/database 0755 ${opts.adminUID} ${opts.adminGID} -"
    "f ${opts.paths.app-data}/filebrowser/database/filebrowser.db 0644 ${opts.adminUID} ${opts.adminGID} -"
    "d ${opts.paths.app-data}/filebrowser/config 0755 ${opts.adminUID} ${opts.adminGID} -"
    "f ${opts.paths.app-data}/filebrowser/config/settings.json 0644 ${opts.adminUID} ${opts.adminGID} -"
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
        "${opts.paths.app-data}/filebrowser/database/filebrowser.db:/database/filebrowser.db"
        "${opts.paths.app-data}/filebrowser/config/settings.json:/config/settings.json"
      ];
      ports = [ "${opts.ports.filebrowser}:8080" ];
      labels = {
        "kuma.filebrowser.http.name" = "Filebrowser";
        "kuma.filebrowser.http.url" = "http://${opts.lanAddress}:${opts.ports.filebrowser}";
      };
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
