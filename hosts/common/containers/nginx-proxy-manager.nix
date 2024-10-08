{opts, ...}: {
  networking.firewall.allowedTCPPorts = [80 81 443];
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
        "${opts.paths.app-data}/npm-data:/data"
        "${opts.paths.app-data}/npm-letsencrypt:/etc/letsencrypt"
      ];
      ports = [
        "80:80"
        "81:81"
        "443:443"
      ];
      labels = {
        "kuma.nginx-proxy-manager.http.name" = "Nginx Proxy Manager";
        "kuma.nginx-proxy-manager.http.url" = "http://${opts.lanAddress}:81";
      };
      environment = {
        TZ = opts.timeZone;
      };
    };
  };
}
