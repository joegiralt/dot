{ opts, ... }:
{
  networking.firewall.allowedTCPPorts = [ 80 81 443 ];
  virtualisation.oci-containers.containers = {
    "nginx-proxy-manager" = {
      autoStart = true;
      image = "jc21/nginx-proxy-manager:latest";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
        "--privileged"
      ];
      volumes = [
        "/mnt/data/appdata/npm-data:/data"
        "/mnt/data/appdata/npm-letsencrypt:/etc/letsencrypt"
      ];
      ports = [
        "80:80"
        "81:81"
        "443:443"
      ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
