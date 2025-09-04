{ config, lib, pkgs, opts, ... }:
{
  # Open Warrior UI port (uses opts.ports.warrior, e.g. 8010)
  networking.firewall.allowedTCPPorts =
    builtins.map pkgs.lib.strings.toInt (with opts.ports; [ warrior ]);

  # Ensure container work dir exists at boot
  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/archiveteam-warrior 0755 ${opts.adminUID} ${opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    "archiveteam-warrior" = {
      autoStart = true;
      image = "archiveteam/warrior-dockerfile:latest";
      extraOptions = [
        "--no-healthcheck"
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--cpus=2"
        "--memory=8g"
      ];
      volumes = [
        "${opts.paths.app-data}/archiveteam-warrior:/data"
      ];
      ports = [ "${opts.ports.warrior}:8001" ];
      labels = {
        "kuma.archiveteam-warrior.http.name" = "ArchiveTeam Warrior";
        "kuma.archiveteam-warrior.http.url" = "http://${opts.lanAddress}:${opts.ports.warrior}";
      };
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;

        DOWNLOADER = opts.warriorDownloader or "joegiralt";
        SELECTED_PROJECT = opts.warriorProject   or "auto";
        CONCURRENT_ITEMS = toString (opts.warriorConcurrent or 4);
      };
    };
  };
}
