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

  environment.etc = {

    "grafana/datasource.yml" = {
      enable = true;
      text = ''
        apiVersion: 1

        datasources:
        - name: Prometheus
          type: prometheus
          url: http://${opts.hostname}:9001
          isDefault: true
          access: proxy
          editable: true
      '';
    };

    "prometheus/prometheus.yml" = {
      enable = true;
      text = ''
        global:
          scrape_interval: 15s
          scrape_timeout: 10s
          evaluation_interval: 15s
        alerting:
          alertmanagers:
          - static_configs:
            - targets: []
            scheme: http
            timeout: 10s
            api_version: v1
        scrape_configs:
        - job_name: prometheus
          honor_timestamps: true
          scrape_interval: 15s
          scrape_timeout: 10s
          metrics_path: /metrics
          scheme: http
          static_configs:
          - targets:
            - localhost:9090
        - job_name: node_exporter
          static_configs:
            - targets:
              - ${opts.hostname}:9002
              - ${opts.hostname}:9134
      '';
    };

  };

  virtualisation.oci-containers.containers = {
    "prometheus" = {
      autoStart = true;
      image = "prom/prometheus";
      extraOptions =
        [ "--add-host=${opts.hostname}:${opts.lanAddress}" "--no-healthcheck" "--user=${opts.adminUID}" ];
      ports = [ "9001:9090" ];
      labels = {
        "kuma.prometheus.http.name" = "Prometheus";
        "kuma.prometheus.http.url" = "http://${opts.lanAddress}:9001";
      };
      volumes = [
        "/etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro"
        "${opts.paths.app-data}/prometheus/data:/prometheus"
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
      labels = {
        "kuma.grafana.http.name" = "Grafana";
        "kuma.grafana.http.url" = "http://${opts.lanAddress}:2200";
      };
      volumes = [
        "/etc/grafana/datasource.yml:/etc/grafana/provisioning/datasources/datasource.yml:ro"
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
