# NOTE: empty files are invalid in nix, so adding an empty attribute set to satisfy nix fmt
{
}
# {
#   config,
#   pkgs,
#   opts,
#   ...
# }:
# {
#   services.xserver.videoDrivers = ["nvida"];

# #   services.nvidia-container-toolkit = {
# #     enable = true;
# #     # drivers = [ "nvidia-container-toolkit" ];
# #   };

#   systemd.tmpfiles.rules = [
#     "C+ /etc/cdi 0755 root root - -"
#   ];

#   systemd.services.nvidia-cdi-setup = {

#     description = "NVIDIA CDI Setup";
#     wantedBy = [ "multi-user.target" ];
#     serviceConfig = {
#       Type = "oneshot";
#       ExecStart = "${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml";
#     };
#   };
# }
