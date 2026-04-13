{
  config,
  opts,
  pkgs,
  ...
}:
let
  port = builtins.fromJSON opts.ports.attic;
in
{
  networking.firewall.allowedTCPPorts = [ port ];

  environment.systemPackages = [ pkgs.attic-client ];

  services.atticd = {
    enable = true;

    environmentFile = config.age.secrets.attic-credentials.path;

    settings = {
      listen = "[::]:${toString port}";

      database.url = "sqlite:///var/lib/atticd/server.db?mode=rwc";

      storage = {
        type = "local";
        path = "/var/lib/atticd/storage";
      };

      # Allow large NAR uploads from CI builds
      chunking = {
        nar-size-threshold = 65536; # 64 KiB
        min-size = 16384; # 16 KiB
        avg-size = 65536; # 64 KiB
        max-size = 262144; # 256 KiB
      };

      garbage-collection = {
        interval = "72 hours";
        default-retention-period = "30 days";
      };
    };
  };
}
