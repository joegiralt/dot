{ config, lib, pkgs, opts, ... }: {

  networking.firewall.allowedTCPPorts = [ 8080 11434 ];

  virtualisation.oci-containers.containers = {
    "ollama" = {
      autoStart = true;
      image = "ollama/ollama";
      extraOptions =
        [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" ];
      volumes = [ 
        "${opts.paths.app-data}/ollama:/root/.ollama" 
        ];
      ports = [ "11434:11434" ];
      labels = {
        "kuma.ollama.http.name" = "Ollama";
        "kuma.ollama.http.url" = "http://${opts.lanAddress}:11434";
      };
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
        "${opts.paths.app-data}/ollama-web:/app/backend/data"
      ];
      ports = [ "8080:8080" ];
      labels = {
        "kuma.ollama-web.http.name" = "Ollama Web";
        "kuma.ollama-web.http.url" = "http://${opts.lanAddress}:8080";
      };
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
