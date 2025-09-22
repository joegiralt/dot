{ inputs, ... }:
prev: next: {
  lmms = inputs.stablepkgs.legacyPackages.${prev.system}.lmms;
  jellyfin-media-player = inputs.stablepkgs.legacyPackages.${prev.system}.jellyfin-media-player;
}
