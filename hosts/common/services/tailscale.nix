{ pkgs, opts, config, ... }:
{
  networking.firewall =
    {
      allowedTCPPorts = [ 41641 ];
      allowedUDPPorts = [ 41641 ];
    };
  services.tailscale = {
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
