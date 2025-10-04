{ inputs, ... }:
prev: _: {
  wezterm = inputs.wezterm.packages.${prev.system}.default;
}
