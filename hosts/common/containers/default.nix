{ pkgs, ... }:
{
  imports = [
    ./homer.nix
    ./nginx-proxy-manager.nix
    ./ollama.nix
    ./telemetry.nix
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = false;
    autoPrune.enable = true;
  };

  environment.systemPackages = with pkgs; [
    dive
    podman-tui
    podman-compose
  ];

}
