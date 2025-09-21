{
  pkgs,
  opts,
  config,
  ...
}:
{
  networking.firewall = {
    checkReversePath = "loose";
    allowedTCPPorts = [ 41641 ];
    allowedUDPPorts = [ 41641 ];
  };
  services.tailscale = {
    useRoutingFeatures = "both"; # (or "server"/client", if you want to use the machine itself as an exit node)
    enable = true;
    port = 41641;
    openFirewall = true;
    authKeyFile = config.age.secrets.tailscale-auth-key.path;
    extraSetFlags = [
      "--exit-node=es-mad-wg-102.mullvad.ts.net."
      "--exit-node-allow-lan-access"
    ];
  };
}
