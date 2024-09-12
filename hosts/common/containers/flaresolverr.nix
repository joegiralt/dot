{
  config,
  lib,
  pkgs,
  opts,
  ...
}: {
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (with opts.ports; [flare-solverr]);
  virtualisation.oci-containers.containers = {
    "flareSolverr" = {
      autoStart = true;
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      extraOptions = ["--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck"];
      ports = ["${opts.ports.flare-solverr}:8191"];
      labels = {
        "kuma.flareSolverr.http.name" = "FlareSolverr";
        "kuma.flareSolverr.http.url" = "http://${opts.lanAddress}:${opts.ports.flare-solverr}";
      };
      environment = {
        LOG_LEVEL = "info";
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
