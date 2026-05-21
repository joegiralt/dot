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
  # Dedicated DNS-disabled network for Woodpecker pipeline containers,
  # kept separate from the shared services network for isolation.
  systemd.services.podman-network-woodpecker-ci = {
    description = "Create Woodpecker CI podman network";
    after = [ "podman.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.podman}/bin/podman network create --disable-dns --ignore woodpecker-ci";
    };
  };

  systemd.services.podman-woodpecker-agent.after = [ "podman-network-woodpecker-ci.service" ];
  systemd.services.podman-woodpecker-agent.wants = [ "podman-network-woodpecker-ci.service" ];

  # The Woodpecker agent is stateless across restarts: any pipeline interrupted
  # by an agent restart / OOM / system event leaves its per-step containers and
  # workspace volume behind, since the new agent process has no record of the
  # in-flight pipeline to clean up. Over weeks these orphans accumulate (we hit
  # ~80G across 32 stopped containers and 23 dangling workspace volumes before
  # the first sweep). This pre-start sweep reaps them on every agent boot. It
  # only touches the `wp_` namespace and only exited containers, so any
  # in-flight pipeline (none exist pre-start by definition) is safe.
  systemd.services.podman-woodpecker-agent.serviceConfig.ExecStartPre = pkgs.writeShellScript "woodpecker-orphan-sweep" ''
    set -u
    ${pkgs.podman}/bin/podman ps -aq --filter name=wp_ --filter status=exited \
      | xargs -r ${pkgs.podman}/bin/podman rm -f >/dev/null 2>&1 || true
    for v in $(${pkgs.podman}/bin/podman volume ls -q --filter name=wp_); do
      ${pkgs.podman}/bin/podman volume rm "$v" >/dev/null 2>&1 || true
    done
  '';

  # Ensure the CI build cache directory exists with open permissions.
  # Pipeline containers may run as non-root, so the directory must be world-writable.
  # cargo-target is intentionally NOT persisted: per-branch target dirs grew unbounded
  # and filled /mnt/data. cargo-home/registry is small and worth keeping for crate downloads.
  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/woodpecker/cache/cargo-home 0777 root root -"
  ];

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
        WOODPECKER_HOST = "https://athena0.tail7424b4.ts.net:8443";
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
        WOODPECKER_BACKEND_DOCKER_NETWORK = "woodpecker-ci";
        WOODPECKER_BACKEND_DOCKER_VOLUMES = "${opts.paths.app-data}/woodpecker/cache/cargo-home:/tmp/cargo-home";
        WOODPECKER_BACKEND_DOCKER_LIMIT_CPU_SET = "2-15";
        WOODPECKER_MAX_WORKFLOWS = "2";
        TZ = opts.timeZone;
      };
    };
  };
}
