{ inputs, ... }:
prev: next: {
  wezterm = inputs.wezterm.packages.${prev.system}.default;
}
