{ opts, ... }:
{
  networking.firewall.allowedTCPPorts = [ 83 ];
  virtualisation.oci-containers.containers = {
    "homer" = {
      autoStart = true;
      image = "b4bz/homer:latest";
      extraOptions =
        [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" ];
      volumes = [ "/mnt/data/appdata/homer/:/www/assets" ];
      ports = [ "83:8080" ];
      labels = {
        "kuma.ntfy.http.name" = "Homer";
        "kuma.ntfy.http.url" = "http://${opts.lanAddress}:83";
      };
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
