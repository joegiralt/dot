{
  pkgs,
  opts,
  hostname,
  ...
}:
{
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports; [ warrior ]
  );

  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/archiveteam-warrior 0755 ${opts.adminUID} ${opts.adminGID} -"
  ];

  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers."archiveteam-warrior" = {
    autoStart = true;
    image   = "atdr.meo.ws/archiveteam/warrior-dockerfile:latest";
    volumes = [ "${opts.paths.app-data}/archiveteam-warrior:/data" ];
    ports   = [ "${toString opts.ports.warrior}:8001" ];
    labels  = {
      "kuma.${opts.hostname}.group.name"     = "${opts.hostname}";
      "kuma.archivewarrior.http.parent_name" = "${opts.hostname}";
      "kuma.archivewarrior.http.name"        = "ArchiveWarrior";
      "kuma.archivewarrior.http.url"         = "http://${opts.lanAddress}:${opts.ports.warrior}";
    };

    extraOptions = [
      "--no-healthcheck"
      "--add-host=${opts.hostname}:${opts.lanAddress}"
      "--cpus=2"
      "--memory=8g"
    ];

    environment = {
      CONCURRENT_ITEMS = "6";
      DOWNLOADER       = hostname;
      PGID             = opts.adminGID;
      PUID             = opts.adminUID;
      SELECTED_PROJECT = "auto";
      TZ               = opts.timeZone;
    };
  };
}
