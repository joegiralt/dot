{
  pkgs,
  opts,
  config,
  ...
}:
{
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports;
    [
      woodpecker-http
      woodpecker-grpc
    ]
  );
  virtualisation.oci-containers.containers = {
    woodpecker-server = {
      autoStart = true;
      image = "woodpeckerci/woodpecker-server:v3";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      ports = [
        "${opts.ports.woodpecker-http}:8000"
        "${opts.ports.woodpecker-grpc}:9000"
      ];
      volumes = [
        "${opts.paths.app-data}/woodpecker/server:/data"
        "${config.age.secrets.woodpecker-github-app-pem.path}:/etc/woodpecker/github-app.pem:ro"
      ];
      environmentFiles = [
        config.age.secrets.woodpecker-env.path
      ];
      labels = {
        "kuma.woodpecker.http.name" = "Woodpecker CI";
        "kuma.woodpecker.http.url" = "http://${opts.lanAddress}:${opts.ports.woodpecker-http}";
      };
      environment = {
        WOODPECKER_HOST = "https://athena0.tail7424b4.ts.net";
        WOODPECKER_OPEN = "false";
        WOODPECKER_ADMIN = "joegiralt";
        WOODPECKER_FORGE_TYPE = "github";
        WOODPECKER_GITHUB_APP_PRIVATE_KEY = "/etc/woodpecker/github-app.pem";
        WOODPECKER_DATABASE_DRIVER = "sqlite3";
        WOODPECKER_DATABASE_DATASOURCE = "/data/woodpecker.sqlite";
        WOODPECKER_GRPC_ADDR = "0.0.0.0:9000";
        WOODPECKER_SERVER_ADDR = "0.0.0.0:8000";
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };

    woodpecker-agent = {
      autoStart = true;
      image = "woodpeckerci/woodpecker-agent:v3";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
      ];
      dependsOn = [ "woodpecker-server" ];
      volumes = [
        "${opts.paths.podman-socket}:/var/run/docker.sock:ro"
      ];
      environmentFiles = [
        config.age.secrets.woodpecker-env.path
      ];
      environment = {
        WOODPECKER_SERVER = "${opts.hostname}:${opts.ports.woodpecker-grpc}";
        WOODPECKER_BACKEND_DOCKER_API_VERSION = "1.43";
        WOODPECKER_MAX_WORKFLOWS = "2";
        TZ = opts.timeZone;
      };
    };
  };
}
