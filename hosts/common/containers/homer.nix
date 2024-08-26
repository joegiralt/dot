{ opts, ... }: 
{
  networking.firewall.allowedTCPPorts = [ 80 ];
  virtualisation.oci-containers.containers = {
    "homer" = {
      autoStart = true;
      image = "b4bz/homer:latest";
      extraOptions =
        [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" ];
      volumes = [ "/mnt/data/appdata/homer/:/www/assets" ];
      ports = [ "80:8080" ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
