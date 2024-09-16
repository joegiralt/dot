# {
#   config,
#   pkgs,
#   opts,
#   ...
# }: 
# {
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
#     install.wantedBy = [ "multi-user.target" ];
#   };
# }
