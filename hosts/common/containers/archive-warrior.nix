{ config, lib, pkgs, opts, ... }:
{
  virtualisation.oci-containers.backend = "podman";

  networking.firewall.allowedTCPPorts =
    builtins.map pkgs.lib.strings.toInt (with opts.ports; [ warrior ]);

  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/archiveteam-warrior 0755 ${toString opts.adminUID} ${toString opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers."archiveteam-warrior" = {
    autoStart = true;

    image = "archiveteam/warrior-dockerfile@sha256:<digest>";

    extraOptions = [
      "--no-healthcheck"
      "--add-host=${opts.hostname}:${opts.lanAddress}"
      "--cpus=2"
      "--memory=8g"
      "--network=host"
    ];

    volumes = [
      "${opts.paths.app-data}/archiveteam-warrior:/data"
      "${opts.paths.app-data}/archiveteam-warrior/wget-at:/usr/local/bin/wget-at:ro"
    ];

    # only used if you didn't switch to --network=host
    ports = [ "${toString opts.ports.warrior}:8001" ];

    labels = {
      "kuma.archiveteam-warrior.http.name" = "ArchiveTeam Warrior";
      "kuma.archiveteam-warrior.http.url" = "http://${opts.lanAddress}:${toString opts.ports.warrior}";
    };

    environment = {
      TZ = opts.timeZone;
      # these are mostly no-ops for this image, harmless to leave:
      PUID = toString opts.adminUID;
      PGID = toString opts.adminGID;
      
      DOWNLOADER = opts.warriorDownloader or "joegiralt";
      SELECTED_PROJECT = opts.warriorProject   or "auto";
      CONCURRENT_ITEMS = toString (opts.warriorConcurrent or 4);

      WGET_AT = "/usr/local/bin/wget-lua";
    };
  };

  systemd.services."podman-archiveteam-warrior" = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    unitConfig.RequiresMountsFor = [ "${opts.paths.app-data}" ];

    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "10s";

      ExecStartPre = [
        "${pkgs.podman}/bin/podman rm -f archiveteam-warrior || true"
        "${pkgs.podman}/bin/podman pull ${config.virtualisation.oci-containers.containers.archiveteam-warrior.image}"
      ];

      ExecStartPost = "${pkgs.podman}/bin/podman exec --user root archiveteam-warrior sh -c 'ln -sf /usr/local/bin/wget-lua /usr/local/bin/wget-at'";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
