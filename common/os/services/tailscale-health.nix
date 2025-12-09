{ pkgs, opts, ... }:
{
  systemd.services."tailscale-health" = {
    description = "Tailscale exit node health checker";
    serviceConfig = {
      Type = "oneshot";
      User = "${opts.username}";
      WorkingDirectory = "/home/${opts.username}/.dot";
      ExecStart = "${pkgs.ruby}/bin/rake tailscale:health";
      Environment = "PATH=/run/current-system/sw/bin:${pkgs.ruby}/bin";
    };
  };
  
  systemd.timers."tailscale-health" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "10min";
    };
  };
}