{ pkgs, opts, ... }:
{
  networking.firewall.allowedTCPPorts =
    [
      2200 # grafana 
      19999 # netdata
      9001 # prometheus_app
      9002 # prometheus_node
    ];

  services.prometheus.exporters.node = {
    enable = true;
    port = 9002;
    # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/exporters.nix
    enabledCollectors = [ "systemd" ];
    # /nix/store/zgsw0yx18v10xa58psanfabmg95nl2bb-node_exporter-1.8.1/bin/node_exporter  --help
    extraFlags = [
      "--collector.ethtool"
      "--collector.softirqs"
      "--collector.tcpstat"
      "--collector.wifi"
      "--collector.zfs"
      "--collector.processes"
      "--collector.filesystem"
    ];
  };

  virtualisation.oci-containers.containers = {
    "prometheus" = {
      autoStart = true;
      image = "prom/prometheus";
      extraOptions =
        [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" "--user=${opts.adminUID}" ];
      ports = [ "9001:9090" ];
      volumes = [
        "/mnt/data/appdata/prometheus/config:/etc/prometheus"
        "/mnt/data/appdata/prometheus/data:/prometheus"
      ];
      cmd = [ "--config.file=/etc/prometheus/prometheus.yml" ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };

    "grafana" = {
      autoStart = true;
      image = "grafana/grafana";
      extraOptions =
        [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" "--user=${opts.adminUID}" ];
      ports = [ "2200:3000" ];
      volumes = [
        "/mnt/data/appdata/grafana/config:/etc/grafana/provisioning/datasources"
        "/mnt/data/databases/grafana:/var/lib/grafana"
      ];
      environment = {
        TZ = opts.timeZone;
        PUID = opts.adminUID;
        PGID = opts.adminGID;
      };
    };
  };
}
