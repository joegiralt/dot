{ pkgs, opts, ... }:
{
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports; [ kavita ]
  );

  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/kavita 0755 ${opts.adminUID} ${opts.adminGID} -"
    "d ${opts.paths.books}           0755 ${opts.adminUID} ${opts.adminGID} -"
    "d ${opts.paths.magazines}       0755 ${opts.adminUID} ${opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    "kavita" = {
      autoStart = true;
      image = "jvmilazz0/kavita:latest";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      ports = [ "${opts.ports.kavita}:5000" ];
      volumes = [
        "${opts.paths.app-data}/kavita:/kavita/config"
        "${opts.paths.books}:/books"
        "${opts.paths.magazines}:/magazines"
      ];

      labels = {
        "kuma.${opts.hostname}.group.name" = "${opts.hostname}";
        "kuma.kavita.http.parent_name" = "${opts.hostname}";
        "kuma.kavita.http.name" = "Kavita";
        "kuma.kavita.http.url" = "http://${opts.lanAddress}:${opts.ports.kavita}";
      };

      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
