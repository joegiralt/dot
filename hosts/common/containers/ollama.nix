{ config, lib, pkgs, opts, ... }: {

  networking.firewall.allowedTCPPorts = [ 8080 11434 ];

  virtualisation.oci-containers.containers = {
    "ollama" = {
      autoStart = true;
      image = "ollama/ollama";
      extraOptions =
        [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" ];
      # volumes = [ "${opts.paths.application_data}/Ollama:/root/.ollama" ]; # TODO: ENABLE THIS TO HAVE PERSISTENT STORAGE
      ports = [ "11434:11434" ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };

    "ollama-web" = {
      autoStart = true;
      image = "ghcr.io/open-webui/open-webui:main";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--add-host=host.docker.internal:host-gateway"
        "--no-healthcheck"
      ];
      volumes = [
        # "${opts.paths.application_data}/OllamaWeb:/app/backend/data" # TODO: ENABLE THIS TO HAVE PERSISTENT STORAGE
      ];
      ports = [ "8080:8080" ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
