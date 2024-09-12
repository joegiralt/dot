{
  config,
  pkgs,
  opts,
  ...
}: {
  networking.firewall.allowedTCPPorts = [53 3000];
  networking.firewall.allowedUDPPorts = [53];
  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = 3000;
    mutableSettings = false;
    openFirewall = true;
    extraArgs = [];
    settings = {
      statistics = {
        interval = "48h";
        enabled = true;
      };
      filters = [
        {
          enabled = true;
          url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.plus.txt";
          name = "HaGeZi's Pro++ DNS Blocklist";
          ID = 1;
        }
        {
          enabled = true;
          url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/tif.txt";
          name = "HaGeZi's Threat Intelligence Feeds DNS Blocklist";
          ID = 2;
        }
        {
          enabled = true;
          url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/fake.txt";
          name = "HaGeZi's Fake DNS Blocklist";
          id = 3;
        }
        {
          enabled = true;
          url = "https://raw.githubusercontent.com/ph00lt0/blocklists/master/blocklist.txt";
          name = "ph00lt0 Blocklist";
          id = 4;
        }
        {
          enabled = true;
          url = "https://blocklistproject.github.io/Lists/adguard/ads-ags.txt";
          name = "blocklist-project-ads";
          id = 5;
        }
        {
          enabled = true;
          url = "https://blocklistproject.github.io/Lists/adguard/crypto-ags.txt";
          name = "blocklist-project-crypto";
          id = 6;
        }
        {
          enabled = false;
          url = "https://blocklistproject.github.io/Lists/adguard/facebook-ags.txt";
          name = "blocklist-project-facebook";
          id = 7;
        }
        {
          enabled = true;
          url = "https://blocklistproject.github.io/Lists/adguard/fraud-ags.txt";
          name = "blocklist-project-fraud";
          id = 8;
        }
        {
          enabled = true;
          url = "https://blocklistproject.github.io/Lists/adguard/tiktok-ags.txt";
          name = "blocklist-project-tiktok";
          id = 9;
        }
        {
          enabled = true;
          url = "https://blocklistproject.github.io/Lists/adguard/tracking-ags.txt";
          name = "blocklist-project-tracking";
          id = 10;
        }
      ];
      user_rules = [
        "@@||1337x.to^$important"
        "@@||a2z.com^$important"
        "@@||airbrake.io^$important"
        "@@||amazonaws.com^$important"
        "@@||audioboom.com^$important"
        "@@||aws.dev^$important"
        "@@||blog.codinghorror.com^$important"
        "@@||buffer.com^$important"
        "@@||download.nvidia.com^$important"
        "@@||engineering.fb.com^$important"
        "@@||feeds.hanselman.com^$important"
        "@@||finance.yahoo.com^$important"
        "@@||kickasstorrents.to^$important"
        "@@||maheshba.bitbucket.io^$important"
        "@@||news.yahoo.com^$important"
        "@@||one.newrelic.com^$important"
        "@@||sports.yahoo.com^$important"
        "@@||thepiratebay.org^$important"
        "@@||torlock.com^$important"
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
        bootstrap_dns = ["9.9.9.9" "1.1.1.1" "1.0.0.1"];
        ratelimit = 500;
        upstream_dns = [
          "https://extended.dns.mullvad.net/dns-query"
          "https://dns10.quad9.net/dns-query"
          "https://dns.cloudflare.com/dns-query"
          "https://adblock.doh.mullvad.net/dns-query"
          "https://dns.nextdns.io"
        ];
        upstream_mode = "load_balance";
      };
    };
  };
}
