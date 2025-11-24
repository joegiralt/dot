{ inputs, ... }:
prev: _: {
  inherit (inputs.stablepkgs.legacyPackages.${prev.stdenv.hostPlatform.system})
    lmms
    jellyfin-media-player
    ledger
    libvdpau-va-gl
    onnxruntime
    sonic-pi
    awscli2
    wezterm
    ;
}
