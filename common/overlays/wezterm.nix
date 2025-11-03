{ inputs, ... }:
prev: _: {
  wezterm = inputs.wezterm.packages.${prev.stdenv.hostPlatform.system}.default;
}
