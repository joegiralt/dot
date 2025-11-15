{ pkgs, config, ... }:
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    package = config.lib.nixGL.wrap pkgs.wezterm;

    extraConfig = ''
      local wezterm = require "wezterm"

      local config = {}
      if wezterm.config_builder then
        config = wezterm.config_builder()
      end

      -- Backend: be conservative for now
      -- "OpenGL" is usually safer than "WebGpu" on mixed setups
      config.front_end = "OpenGL"

      -- Font: keep this, it should work with your nerd fonts
      config.font = wezterm.font_with_fallback {
        "JetBrainsMono Nerd Font",
        "Noto Color Emoji",
      }
      config.font_size = 13.0

      -- DO NOT set color_scheme until we know the exact name
      -- config.color_scheme = "Gruvbox Dark"

      -- Tabs & UI
      config.hide_tab_bar_if_only_one_tab = true
      config.use_fancy_tab_bar = true
      config.tab_max_width = 32

      -- Window look
      config.window_decorations = "RESIZE"
      config.window_padding = {
        left = 6,
        right = 6,
        top = 4,
        bottom = 4,
      }

      -- Slight transparency
      config.window_background_opacity = 0.95

      -- Cursor style
      config.default_cursor_style = "SteadyBar"

      -- No scroll bar
      config.enable_scroll_bar = false

      return config
    '';
  };
}
