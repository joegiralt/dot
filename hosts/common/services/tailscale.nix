{ pkgs, opts, ... }:
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
  };
}
