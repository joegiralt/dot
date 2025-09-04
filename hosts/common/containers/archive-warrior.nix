{ config, lib, pkgs, opts, ... }:
let
  # tiny wrapper stored in the Nix store, bind-mounted read-only into the container
  wgetAt = pkgs.writeScript "wget-at" ''
    #!${pkgs.bash}/bin/bash
    exec /usr/local/bin/wget-lua "$@"
  '';
in
{
  # open the UI port
  networking.firewall.allowedTCPPorts =
    builtins.map pkgs.lib.strings.toInt (with opts.ports; [ warrior ]);

  # ensure the data dir exists (same pattern as your other apps)
  systemd.tmpfiles.rules = [
    "d ${opts.paths.app-data}/archiveteam-warrior 0755 ${toString opts.adminUID} ${toString opts.adminGID} -"
  ];

  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers."archiveteam-warrior" = {
    autoStart = true;
    image = "archiveteam/warrior-dockerfile:latest";  # keep it simple; pin later if you want
    volumes = [
      "${opts.paths.app-data}/archiveteam-warrior:/data"
      # provide wget-at inside the container on every start
      "${wgetAt}:/usr/local/bin/wget-at:ro"
    ];
    ports   = [ "${toString opts.ports.warrior}:8001" ];
    # if your other apps use host networking, you can do that instead:
    # extraOptions = [ "--network=host" "--no-healthcheck" "--cpus=2" "--memory=8g" "--add-host=${opts.hostname}:${opts.lanAddress}" ];
    extraOptions = [
      "--no-healthcheck"
      "--add-host=${opts.hostname}:${opts.lanAddress}"
      "--cpus=2"
      "--memory=8g"
    ];
    labels = {
      "kuma.archiveteam-warrior.http.name" = "ArchiveTeam Warrior";
      "kuma.archiveteam-warrior.http.url"  = "http://${opts.lanAddress}:${toString opts.ports.warrior}";
    };
    environment = {
      TZ = opts.timeZone;
      PUID = toString opts.adminUID;   # harmless here
      PGID = toString opts.adminGID;

      DOWNLOADER       = opts.warriorDownloader or "joegiralt";
      SELECTED_PROJECT = opts.warriorProject    or "auto";
      CONCURRENT_ITEMS = toString (opts.warriorConcurrent or 4);

      # belt-and-suspenders: some pipelines look at this
      WGET_AT = "/usr/local/bin/wget-lua";
    };
  };
}
