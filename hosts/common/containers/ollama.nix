{
  config,
  lib,
  pkgs,
  opts,
  ...
}: {
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports; [
      ollama
      ollama-web
    ]
  );

  virtualisation.oci-containers.containers = {
    "ollama" = {
      autoStart = true;
      image = "ollama/ollama:latest";
      extraOptions = [
        "--gpus=all"
        "--add-host=${opts.hostname}:${opts.lanAddress}" 
        "--no-healthcheck" 
        ];      
      volumes = [
        "${opts.paths.app-data}/ollama:/root/.ollama"
      ];
      ports = ["${opts.ports.ollama}:11434"];
      labels = {
        "kuma.ollama.http.name" = "Ollama";
        "kuma.ollama.http.url" = "http://${opts.lanAddress}:${opts.ports.ollama}";
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
      ports = ["${opts.ports.ollama-web}:8080"];
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
