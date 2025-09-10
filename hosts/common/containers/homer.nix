{
  opts,
  pkgs,
  ...
}:
let
  homerConfigDirectory = builtins.path {
    name = "homer-config";
    path = ../configurations/homer;
  };
in
{
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports; [ homer ]
  );
  virtualisation.oci-containers.containers = {
    "homer" = {
      autoStart = true;
      image = "b4bz/homer:latest";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      volumes = [
        "${homerConfigDirectory}:/www/assets:ro"
      ];
      ports = [ "${opts.ports.homer}:8080" ];
      labels = {
        "kuma.homer.http.name" = "Homer";
        "kuma.homer.http.url" = "http://${opts.lanAddress}:${opts.ports.homer}";
      };
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
