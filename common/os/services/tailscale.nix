{ config, opts, ... }:
{
  networking.firewall = {
    checkReversePath = "loose";
    allowedTCPPorts = [
      41641
      8443 # Tailscale Funnel for Woodpecker
    ];
    allowedUDPPorts = [ 41641 ];
  };
  services.tailscale = {
    useRoutingFeatures = "both"; # (or "server"/client", if you want to use the machine itself as an exit node)
    enable = true;
    port = 41641;
    openFirewall = true;
    authKeyFile = config.age.secrets.tailscale-auth-key.path;
    extraSetFlags = [
      "--exit-node=es-bcn-wg-001.mullvad.ts.net."
      "--exit-node-allow-lan-access"
    ];
  };

  # Tailscale Funnel: expose Woodpecker CI to the public internet
  # so GitHub can deliver webhooks.
  systemd.services.tailscale-funnel-woodpecker = {
    description = "Tailscale Funnel for Woodpecker CI";
    after = [
      "tailscaled-autoconnect.service"
      "podman-woodpecker-server.service"
    ];
    wants = [ "tailscaled-autoconnect.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ config.services.tailscale.package ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.services.tailscale.package}/bin/tailscale funnel --bg --https=8443 http://localhost:${opts.ports.woodpecker-http}";
      ExecStop = "${config.services.tailscale.package}/bin/tailscale funnel --https=8443 off";
    };
  };
}
