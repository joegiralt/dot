{ config
, lib
, pkgs
, opts
, ...
}:
let
  appData = opts.paths."app-data";
  portsList =
    with opts.ports; [
      portainer_misc
      portainer_web
      portainer_web_secure
    ];
in
{
  networking.firewall.allowedTCPPorts =
    builtins.map (x: pkgs.lib.strings.toInt x) portsList;

  systemd.tmpfiles.rules = [
    "d ${appData}/portainer 0755 ${toString opts.adminUID} ${toString opts.adminGID} -"
  ];

  virtualisation.oci-containers.containers = {
    "portainer" = {
      autoStart = true;
      image = "portainer/portainer-ce:latest";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      ports = [
        "${toString opts.ports.portainer_misc}:8000"
        "${toString opts.ports.portainer_web_secure}:9443"
        "${toString opts.ports.portainer_web}:9000"
      ];
      volumes = [
        "/run/podman/podman.sock:/var/run/docker.sock"
        "${appData}/portainer:/data"
      ];
      labels = {
        "kuma.portainer.http.name" = "Portainer (HTTP)";
        "kuma.portainer.http.url" =
          "http://${opts.lanAddress}:${toString opts.ports.portainer_web}";
        "kuma.portainer.https.name" = "Portainer (HTTPS)";
        "kuma.portainer.https.url" =
          "https://${opts.lanAddress}:${toString opts.ports.portainer_web_secure}";
      };
      environment = {
        TZ = opts.timeZone;
        PUID = toString opts.adminUID;
        PGID = toString opts.adminGID;
      };
    };
  };
}
