{
  opts,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [
    53
    3000
  ];
  networking.firewall.allowedUDPPorts = [ 53 ];
  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = 3000;
    mutableSettings = false;
    openFirewall = true;
    extraArgs = [ ];
    settings = {
      clients = {
        persistent = [
          {
            name = "apollo"; # kids machine
            ids = [ "192.168.1.55" ];

            use_global_blocked_services = false;

            blocked_services = {
              ids = [ "youtube" ];

              schedule = {
                time_zone = "Europe/Madrid";

                mon = {
                  start = "17h";
                  end = "19h";
                };
                tue = {
                  start = "17h";
                  end = "19h";
                };
                wed = {
                  start = "17h";
                  end = "19h";
                };
                thu = {
                  start = "17h";
                  end = "19h";
                };
                fri = {
                  start = "17h";
                  end = "19h";
                };

                # Sat–Sun allow 9:00–11:00
                sat = {
                  start = "9h";
                  end = "11h";
                };
                sun = {
                  start = "9h";
                  end = "11h";
                };
              };
            };
          }
        ];
      };
      statistics = {
        interval = "48h";
        enabled = true;
      };
      querylog = {
        enabled = true;
        file_enabled = false;
        size_memory = 10000;
        interval = "1h";
      };
      filters = [
        {
          enabled = true;
          url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
          name = "Hagezi's Multi Pro (recommended)";
          ID = 1;
        }
        {
          enabled = false;
          url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.plus.txt";
          name = "Hagezi's Multi Pro++ (aggressive)";
          ID = 2;
        }
        {
          enabled = false;
          url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/ultimate.txt";
          name = "Hagezi's Multi Ultimate (hardcore)";
          ID = 3;
        }
        {
          enabled = true;
          url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/fake.txt";
          name = "Hagezi's Fakesites List";
          ID = 4;
        }
      ];
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        filters_update_interval = 8;
        rewrites = [
          {
            domain = "${opts.hostname}.internal";
            answer = opts.lanAddress;
          }
        ];
      };
      dns = {
        bind_host = "0.0.0.0";
        cache_size = 1000000;
        cache_ttl_min = 3600;
        cache_ttl_max = 86400;
        cache_optimistic = true;
        bootstrap_dns = [
          "9.9.9.9"
          "1.1.1.1"
          "1.0.0.1"
        ];
        ratelimit = 500;
        upstream_dns = [
          "https://dns.cloudflare.com/dns-query"
          "https://dns.google/dns-query"
          "https://dns10.quad9.net/dns-query"
          "tls://dns10.quad9.net"
        ];
        upstream_mode = "load_balance";
      };
    };
  };
}
