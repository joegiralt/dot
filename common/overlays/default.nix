{ inputs, ... }:
[
  inputs.nixgl.overlay
  inputs.nur.overlays.default
  (import ./agenix.nix { inherit inputs; })
  (import ./stable.nix { inherit inputs; })
  (import ./nvidia.nix { inherit inputs; })
  (import ./colmena.nix { inherit inputs; })
  inputs.claude-code.overlays.default
  inputs.claude-desktop.overlays.default
]
