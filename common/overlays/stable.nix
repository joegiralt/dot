{ inputs, ... }:
prev: _: {
  inherit (inputs.stablepkgs.legacyPackages.${prev.system}) lmms jellyfin-media-player;
}
