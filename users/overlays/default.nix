{ inputs, ... }:
[
  inputs.nixgl.overlay
  (import ./agenix.nix { inherit inputs; })
  (import ./stable.nix { inherit inputs; })
  (import ./wezterm.nix { inherit inputs; })
  (import ./nvidia.nix { inherit inputs; })
]
