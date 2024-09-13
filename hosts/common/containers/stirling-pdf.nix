{ pkgs
, opts
, ...
}: {
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports; [
      stirling-pdf
    ]
  );
  virtualisation.oci-containers.containers = {
    "stirling-pdf" = {
      autoStart = true;
      image = "frooodle/s-pdf:latest";
      extraOptions = [ "--no-healthcheck" ];
      volumes = [
        "${opts.paths.app-data}/stirling-pdf/training-data:/usr/share/tessdata"
        "${opts.paths.app-data}/stirling-pdf/extra-configs:/configs"
        "${opts.paths.app-data}/stirling-pdf/logs:/logs"
        "${opts.paths.app-data}/stirling-pdf/custom-files:/custom-files"
      ];
      ports = [ "3456:8080" ];
      labels = {
        "kuma.stirling-pdf.http.name" = "Stirling PDF";
        "kuma.stirling-pdf.http.url" = "http://${opts.lanAddress}:${opts.ports.stirling-pdf}";
      };
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
