{ pkgs, opts, ... }:
{
  # Web panel on crafty port; Crafty hands Minecraft servers ports from 25500-25600.
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports; [ crafty ]
  );
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 25500;
      to = 25600;
    }
  ];

  systemd.tmpfiles.rules =
    map (d: "d ${opts.paths.app-data}/crafty/${d} 0775 ${opts.adminUID} root -")
      [
        "backups"
        "config"
        "import"
        "logs"
        "servers"
      ];

  virtualisation.oci-containers.containers = {
    "crafty" = {
      autoStart = true;
      # Pinned + fully qualified, same reasoning as woodpecker.nix.
      image = "docker.io/arcadiatechnology/crafty-4:4.11.0";
      extraOptions = [
        "--add-host=${opts.hostname}:${opts.lanAddress}"
        "--no-healthcheck"
        # P-cores. Woodpecker CI is confined to E-cores 8-15, so the two never contend.
        "--cpuset-cpus=0-7"
      ];
      # 8443 on the host is taken by the Tailscale funnel for Woodpecker.
      ports = [
        "${opts.ports.crafty}:8443"
        "25500-25600:25500-25600"
      ];
      volumes = [
        "${opts.paths.app-data}/crafty/backups:/crafty/backups"
        "${opts.paths.app-data}/crafty/config:/crafty/app/config"
        "${opts.paths.app-data}/crafty/import:/crafty/import"
        "${opts.paths.app-data}/crafty/logs:/crafty/logs"
        "${opts.paths.app-data}/crafty/servers:/crafty/servers"
      ];

      labels = {
        "kuma.${opts.hostname}.group.name" = "${opts.hostname}";
        "kuma.crafty.http.parent_name" = "${opts.hostname}";
        "kuma.crafty.http.name" = "Crafty";
        "kuma.crafty.http.url" = "https://${opts.lanAddress}:${opts.ports.crafty}";
        "kuma.crafty.http.ignore_tls" = "true";
      };

      environment = {
        TZ = opts.timeZone;
      };
    };
  };
}
