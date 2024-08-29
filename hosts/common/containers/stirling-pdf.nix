{ pkgs, opts, ... }:
{
  networking.firewall.allowedTCPPorts = [ 3456 ];
  virtualisation.oci-containers.containers = {
    "stirling-pdf" = {
      autoStart = true;
      image = "frooodle/s-pdf:latest";
      extraOptions = [ "--no-healthcheck" ];
      volumes = [
        "/mnt/data/appdata/stirling-pdf/training-data:/usr/share/tessdata"
        "/mnt/data/appdata/stirling-pdf/extra-configs:/configs"
        "/mnt/data/appdata/stirling-pdf/logs:/logs"
        "/mnt/data/appdata/stirling-pdf/custom-files:/custom-files"
      ];
      ports = [ "3456:8080" ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
        DOCKER_ENABLE_SECURITY = "false";
        INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "false";
        LANGS = "en_US";
      };
    };
  };
}
