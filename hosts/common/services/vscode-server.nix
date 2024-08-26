{ config, pkgs, opts, ... }: {
  services.openvscode-server = {
    enable = true;
    withoutConnectionToken = true;
    user = "admin";
    port = 2345;
    host = "0.0.0.0";
  };
}
