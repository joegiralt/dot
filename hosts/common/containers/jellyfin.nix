{
  config,
  lib,
  pkgs,
  opts,
  ...
}:
{
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports; [ jellyfin ]
  );

  virtualisation.oci-containers.containers = {
    "jellyfin" = {
      autoStart = true;
      image = "jellyfin/jellyfin";
      volumes = [
        "${opts.paths.app-data}/jellyfin/config:/config"
        "${opts.paths.app-data}/jellyfin/cache/:/cache"
        "${opts.paths.app-data}/jellyfin/log/:/log"
        "${opts.paths.film}:/film"
        "${opts.paths.tv}:/tv"
      ];
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      ports = [ "${opts.ports.jellyfin}:8096" ];
      labels = {
        "kuma.jellyfin.http.name" = "Jellyfin";
        "kuma.jellyfin.http.url" = "http://${opts.lanAddress}:${opts.ports.jellyfin}/health";
      };
      environment = {
        JELLYFIN_LOG_DIR = "/log";
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
