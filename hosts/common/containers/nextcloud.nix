{ config, lib, pkgs, opts, ... }: {

  networking.firewall.allowedTCPPorts = [ 443 80 ];

  virtualisation.oci-containers.containers = {
    "nextcloud" = {
      autoStart = true;
      image = "lscr.io/linuxserver/nextcloud:latest";
      extraOptions =
        [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" ];
      volumes = [
        "/mnt/data/appdata/nextcloud/config:/config"
        "/mnt/data/appdata/nextcloud/data:/data"
      ];
      ports = [ "444:443" "84:80" ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
