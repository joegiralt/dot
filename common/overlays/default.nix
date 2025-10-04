{ inputs, ... }:
[
  inputs.nixgl.overlay
  inputs.nur.overlays.default
  (import ./agenix.nix { inherit inputs; })
  (import ./stable.nix { inherit inputs; })
  (import ./wezterm.nix { inherit inputs; })
  (import ./nvidia.nix { inherit inputs; })
  (import ./colmena.nix { inherit inputs; })
]
