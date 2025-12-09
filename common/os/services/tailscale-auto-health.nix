{ config, pkgs, opts, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/tailscale-exit-health 0755 ${opts.adminUID} ${opts.adminGID} -"
  ];
  
  systemd.services."tailscale-auto-health" = {
    description = "Tailscale Exit Node Health Checker (auto cycle on failure)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "admin"; # TODO: generalize username
      WorkingDirectory = "/home/admin/.dot"; # TODO: generalize working dir

      # Full PATH needed so rake, ruby, curl, ping all resolve
      Environment = "PATH=/run/current-system/sw/bin:${pkgs.ruby}/bin";

      ExecStart = "${pkgs.ruby}/bin/rake tailscale:auto_health";
    };
  };

  systemd.timers."tailscale-auto-health" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "10min";  # run every 10 minutes
      Unit = "tailscale-auto-health.service";
    };
  };
}
