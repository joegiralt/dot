{ config, lib, pkgs, opts, ... }: {
  networking.firewall.allowedTCPPorts = [ 8191 ];
  virtualisation.oci-containers.containers = {
    "flareSolverr" = {
      autoStart = true;
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      extraOptions =
        [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" ];
      ports = [ "8191:8191" ];
      labels = {
        "kuma.ntfy.http.name" = "FlareSolverr";
        "kuma.ntfy.http.url" = "http://${opts.lanAddress}:8191";
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
