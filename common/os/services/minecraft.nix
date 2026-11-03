{
  inputs,
  opts,
  pkgs,
  ...
}:
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    dataDir = "${opts.paths.app-data}/minecraft";

    servers.main = {
      enable = true;
      # Fabric, pinned: clients must run this exact version + the same mods,
      # so a flake.lock bump must never move it. 1.21.1 has the biggest mod catalog.
      # ponytail: mods are unmanaged jars in <dataDir>/main/mods; move to
      # `symlinks.mods` + fetchurl if the list ever needs to be reproducible.
      package = pkgs.fabricServers.fabric-1_21_1;
      jvmOpts = "-Xms2G -Xmx8G";
      serverProperties = {
        server-port = 25565;
        motd = "athena0";
      };
    };
  };

  # Lets admin attach to the server console: tmux -S /run/minecraft/main.sock attach
  users.users.admin.extraGroups = [ "minecraft" ];

  # P-cores (0-7). Woodpecker CI is confined to E-cores 8-15, so the two never contend.
  systemd.services.minecraft-server-main.serviceConfig.CPUAffinity = "0-7";
}
