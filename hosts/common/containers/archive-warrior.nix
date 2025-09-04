{ config, lib, pkgs, opts, ... }:
let
  wgetAtWrapper = pkgs.writeTextFile {
    name = "warrior-wget-at-wrapper";
    executable = true;
    text = ''
      #!/bin/sh
      real=/usr/local/bin/wget-lua
      case "$1" in
        -V|--version)
          "$real" -V | sed '1s/^GNU Wget/Wget+AT/'
          ;;
        *)
          exec "$real" "$@"
          ;;
      esac
    '';
  };
in
{
  networking.firewall.allowedTCPPorts =
    builtins.map pkgs.lib.strings.toInt (with opts.ports; [ warrior ]);

  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/archiveteam-warrior 0755 ${toString opts.adminUID} ${toString opts.adminGID} -"
  ];

  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers."archiveteam-warrior" = {
    autoStart = true;
    image = "atdr.meo.ws/archiveteam/warrior-dockerfile:latest";

    extraOptions = [
      "--no-healthcheck"
      "--add-host=${opts.hostname}:${opts.lanAddress}"
      "--cpus=2"
      "--memory=8g"
    ];

    volumes = [
      "${opts.paths.app-data}/archiveteam-warrior:/data"
      "${wgetAtWrapper}:/usr/local/bin/wget-at:ro"
      "${wgetAtWrapper}:/usr/bin/wget-at:ro"
      "${wgetAtWrapper}:/usr/bin/wget-lua:ro"
    ];

    ports = [ "${toString opts.ports.warrior}:8001" ];

    labels = {
      "kuma.archiveteam-warrior.http.name" = "ArchiveTeam Warrior";
      "kuma.archiveteam-warrior.http.url"  = "http://${opts.lanAddress}:${toString opts.ports.warrior}";
    };

    environment = {
      TZ   = opts.timeZone;
      PUID = toString opts.adminUID;
      PGID = toString opts.adminGID;

      DOWNLOADER       = opts.warriorDownloader or "joegiralt";
      SELECTED_PROJECT = opts.warriorProject    or "auto";
      CONCURRENT_ITEMS = toString (opts.warriorConcurrent or 4);

      WGET_AT  = "/usr/local/bin/wget-at";
      WGET_LUA = "/usr/local/bin/wget-lua";
    };
  };
}
