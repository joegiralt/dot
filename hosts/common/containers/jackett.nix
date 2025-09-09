{
  config,
  lib,
  pkgs,
  opts,
  ...
}:
{
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports; [ jackett ]
  );
  virtualisation.oci-containers.containers = {
    "jackett" = {
      autoStart = true;
      image = "lscr.io/linuxserver/jackett:latest";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      dependsOn = [ "flareSolverr" ];
      environment = {
        AUTO_UPDATE = "true";
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
      volumes = [
        "${opts.paths.app-data}/jackett:/config"
        "${opts.paths.downloads}:/downloads"
      ];
      ports = [ "9117:9117" ];
      labels = {
        "kuma.jackett.http.name" = "Jackett";
        "kuma.jackett.http.url" = "http://${opts.lanAddress}:${opts.ports.jackett}/health";
      };
    };
  };
}
