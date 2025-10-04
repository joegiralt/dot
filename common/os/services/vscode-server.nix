{ pkgs, opts, ... }:
{
  services.openvscode-server = {
    enable = true;
    withoutConnectionToken = true;
    user = "admin";
    port = pkgs.lib.strings.toInt opts.ports.vscode-server;
    host = "0.0.0.0";
  };
  networking.firewall.allowedTCPPorts = builtins.map pkgs.lib.strings.toInt (
    with opts.ports; [ vscode-server ]
  );
}
