{ inputs, ... }:
[
  inputs.nixgl.overlay
  (import ./agenix.nix { inherit inputs; })
  (import ./stable.nix { inherit inputs; })
]
