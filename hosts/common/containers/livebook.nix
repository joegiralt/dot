{ config
, lib
, pkgs
, opts
, ...
}: {
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports; [
      livebook
      livebook-alt
    ]
  );

  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/livebook 0755 ${opts.adminUID} ${opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    livebook = {
      autoStart = true;
      image = "ghcr.io/livebook-dev/livebook:nightly-cuda12";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      volumes = [
        "${opts.paths.app-data}/livebook/:/data"
      ];
      ports = [
        "${opts.ports.livebook}:8080"
        "${opts.ports.livebook-alt}:8081"
      ];
      labels = {
        "kuma.livebook.http.name" = "Livebook";
        "kuma.livebook.http.url" = "http://${opts.lanAddress}:${opts.ports.livebook}";
      };
      environment = {
        LIVEBOOK_UPDATE_INSTRUCTIONS_URL = "true";
        LIVEBOOK_TOKEN_ENABLED = "false";
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
