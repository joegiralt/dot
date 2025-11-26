{ pkgs, config, ... }:
{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    package = config.lib.nixGL.wrap pkgs.wezterm;

    extraConfig = ''
      ------------------------------------------------------------
      -- Joe's Awesome Wezterm Template
      ------------------------------------------------------------
      
      local wezterm = require "wezterm"
      
      ------------------------------------------------------------
      -- Helpers
      ------------------------------------------------------------
      
      local function scheme_for_appearance(appearance)
        if appearance:find("Dark") then
          return "XY-Zed"
        else
          return "XY-Zed"
        end
      end
      
      ------------------------------------------------------------
      -- Base config object
      ------------------------------------------------------------
      
      local config = {}
      
      if wezterm.config_builder then
        config = wezterm.config_builder()
      end
      
      ------------------------------------------------------------
      -- Front-end / performance
      ------------------------------------------------------------
      
      -- Renderer backend
      config.front_end = "OpenGL"            -- "OpenGL", "WebGpu", "Software"
      
      -- GPU behavior
      config.webgpu_power_preference = "HighPerformance" -- or "LowPower"
      config.max_fps = 120
      config.animation_fps = 60
      
      -- Wayland: set false if it misbehaves
      config.enable_wayland = true
      
      ------------------------------------------------------------
      -- Appearance: colors, window, padding
      ------------------------------------------------------------
      local xy_zed = {
        -- Core terminal colors (from terminal.*)
        foreground = "#f7f7f8",          -- terminal.foreground
        background = "#121212",          -- terminal.background
      
        -- Cursor (use the green accent from the theme)
        cursor_bg = "#7de486",           -- players[0].cursor
        cursor_fg = "#121212",           -- dark bg behind it
        cursor_border = "#7de486",
      
        -- Selection
        selection_fg = "#121212",
        -- Zed uses #7de4863d (transparent); wezterm has no alpha in hex, so we use solid accent
        selection_bg = "#7de486",
      
        -- Split lines etc (use a subtle grey from the palette)
        split = "#40434c",               -- terminal.ansi.bright_black
      
        -- Scrollbar thumb (approx from scrollbar.thumb.background)
        scrollbar_thumb = "#aca8ae",
      
        -- ANSI colors (terminal.ansi.*)
        ansi = {
          "#1e2025", -- 0: black          terminal.ansi.black
          "#f82871", -- 1: red            terminal.ansi.red
          "#96df71", -- 2: green          terminal.ansi.green
          "#fee56c", -- 3: yellow         terminal.ansi.yellow
          "#10a793", -- 4: blue (tealish) terminal.ansi.blue
          "#c74cec", -- 5: magenta        terminal.ansi.magenta
          "#08e7c5", -- 6: cyan           terminal.ansi.cyan
          "#f7f7f8", -- 7: white          terminal.ansi.white
        },
      
        brights = {
          "#40434c", -- 8:  bright black   terminal.ansi.bright_black
          "#8e0f3a", -- 9:  bright red     terminal.ansi.bright_red
          "#457c38", -- 10: bright green   terminal.ansi.bright_green
          "#958334", -- 11: bright yellow  terminal.ansi.bright_yellow
          "#1a5148", -- 12: bright blue    terminal.ansi.bright_blue
          "#682681", -- 13: bright magenta terminal.ansi.bright_magenta
          "#008169", -- 14: bright cyan    terminal.ansi.bright_cyan
          "#f7f7f8", -- 15: bright white   terminal.ansi.bright_white
        },
      
        -- Optional: tab bar styling approximating the Zed UI bits
        tab_bar = {
          background = "#1b1b1b",        -- tab_bar.background
      
          active_tab = {
            bg_color = "#121212",        -- tab.active_background
            fg_color = "#f7f7f8",        -- text
            intensity = "Normal",
            underline = "None",
            italic = false,
            strikethrough = false,
          },
      
          inactive_tab = {
            bg_color = "#1b1b1b",        -- tab.inactive_background
            fg_color = "#6b6b73",        -- text.placeholder
            intensity = "Normal",
            underline = "None",
            italic = false,
            strikethrough = false,
          },
      
          inactive_tab_hover = {
            bg_color = "#1b1b1b",
            fg_color = "#aca8ae",        -- text.muted
            intensity = "Bold",
            underline = "None",
            italic = false,
            strikethrough = false,
          },
      
          new_tab = {
            bg_color = "#1b1b1b",
            fg_color = "#6b6b73",
          },
      
          new_tab_hover = {
            bg_color = "#1b1b1b",
            fg_color = "#f7f7f8",
            italic = true,
          },
        },
      }
      
      config.color_schemes = config.color_schemes or {}
      
      config.color_schemes["XY-Zed"] = xy_zed
      
      if wezterm.gui then
        config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
      else
        config.color_scheme = "XY-Zed"
      end
      
      config.window_decorations = "RESIZE"   -- "NONE", "TITLE", "RESIZE", "INTEGRATED_BUTTONS"
      
      config.window_background_opacity = 1.0
      config.text_background_opacity = 1.0
      
      -- Does nothing on Linux but harmless
      config.win32_system_backdrop = "Acrylic"
      
      config.window_padding = {
        left = 4,
        right = 4,
        top = 2,
        bottom = 2,
      }
      
      config.initial_cols = 120
      config.initial_rows = 32
      
      config.adjust_window_size_when_changing_font_size = true
      
      config.use_fancy_tab_bar = true
      config.hide_tab_bar_if_only_one_tab = true
      config.show_new_tab_button_in_tab_bar = true
      config.tab_max_width = 32
      config.show_tab_index_in_tab_bar = true
      
      ------------------------------------------------------------
      -- Fonts
      ------------------------------------------------------------
      
      config.font = wezterm.font_with_fallback {
        "JetBrainsMono Nerd Font",
        "Noto Color Emoji",
      }
      
      config.font_size = 12.0
      config.line_height = 1.0
      config.cell_width = 1.0
      
      config.bold_brightens_ansi_colors = true
      config.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"
      
      -- Font rendering knobs you can play with later
      config.freetype_load_flags = "NO_HINTING"    -- try "DEFAULT" / "NO_HINTING"
      
      ------------------------------------------------------------
      -- Cursor
      ------------------------------------------------------------
      
      config.default_cursor_style = "SteadyBar"    -- "BlinkingBar", "SteadyBlock", etc.
      config.cursor_blink_rate = 0                 -- ms; 0 = no blink
      config.force_reverse_video_cursor = true
      
      ------------------------------------------------------------
      -- Scrollback
      ------------------------------------------------------------
      
      config.scrollback_lines = 10000
      config.enable_scroll_bar = false
      config.scroll_to_bottom_on_input = true
      
      ------------------------------------------------------------
      -- Bell / notifications
      ------------------------------------------------------------
      
      config.audible_bell = "Disabled"             -- "Disabled", "SystemBeep", "Default"
      
      config.visual_bell = {
        fade_in_duration_ms = 75,
        fade_out_duration_ms = 75,
        target = "CursorColor",                    -- or "BackgroundColor"
      }
      
      ------------------------------------------------------------
      -- Key bindings
      ------------------------------------------------------------
      
      local act = wezterm.action
      
      config.leader = {
        key = "a",
        mods = "CTRL",
        timeout_milliseconds = 1000,
      }
      
      config.disable_default_key_bindings = false
      
      config.keys = {
        -- Tabs
        { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab "CurrentPaneDomain" },
        { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab { confirm = true } },
        { key = "Tab", mods = "CTRL",        action = act.ActivateTabRelative(1) },
        { key = "Tab", mods = "CTRL|SHIFT",  action = act.ActivateTabRelative(-1) },
      
        -- Panes
        { key = "%", mods = "CTRL|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
        { key = '"', mods = "CTRL|SHIFT", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
        { key = "h", mods = "CTRL|ALT",   action = act.ActivatePaneDirection "Left" },
        { key = "l", mods = "CTRL|ALT",   action = act.ActivatePaneDirection "Right" },
        { key = "k", mods = "CTRL|ALT",   action = act.ActivatePaneDirection "Up" },
        { key = "j", mods = "CTRL|ALT",   action = act.ActivatePaneDirection "Down" },
        { key = "x", mods = "CTRL|SHIFT", action = act.CloseCurrentPane { confirm = true } },
      
        -- Resize panes
        { key = "LeftArrow",  mods = "CTRL|SHIFT", action = act.AdjustPaneSize { "Left", 2 } },
        { key = "RightArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize { "Right", 2 } },
        { key = "UpArrow",    mods = "CTRL|SHIFT", action = act.AdjustPaneSize { "Up", 1 } },
        { key = "DownArrow",  mods = "CTRL|SHIFT", action = act.AdjustPaneSize { "Down", 1 } },
      
        -- Copy / Paste
        { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo "Clipboard" },
        { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom "Clipboard" },
      
        -- Font size
        { key = "+", mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
        { key = "-", mods = "CTRL|SHIFT", action = act.DecreaseFontSize },
        { key = "0", mods = "CTRL|SHIFT", action = act.ResetFontSize },
      
        -- Scrollback
        { key = "PageUp",   mods = "SHIFT", action = act.ScrollByPage(-1) },
        { key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },
      
        -- Reload config
        { key = "r", mods = "CTRL|SHIFT", action = act.ReloadConfiguration },
      }
      
      ------------------------------------------------------------
      -- Mouse bindings
      ------------------------------------------------------------
      
      config.mouse_bindings = {
        -- Left click selects text
        {
          event = { Up = { streak = 1, button = "Left" } },
          mods = "NONE",
          action = act.CompleteSelection "ClipboardAndPrimarySelection",
        },
        -- Right click paste
        {
          event = { Up = { streak = 1, button = "Right" } },
          mods = "NONE",
          action = act.PasteFrom "Clipboard",
        },
        -- Ctrl + wheel to zoom
        {
          event = { Down = { streak = 1, button = { WheelUp = 1 } } },
          mods = "CTRL",
          action = act.IncreaseFontSize,
        },
        {
          event = { Down = { streak = 1, button = { WheelDown = 1 } } },
          mods = "CTRL",
          action = act.DecreaseFontSize,
        },
      }
      
      ------------------------------------------------------------
      -- Hyperlinks
      ------------------------------------------------------------
      
      config.hyperlink_rules = wezterm.default_hyperlink_rules()
      
      table.insert(config.hyperlink_rules, {
        regex = [[\bPR-(\d+)\b]],
        format = "https://github.com/your-org/your-repo/pull/$1",
      })
      
      ------------------------------------------------------------
      -- Shell / program
      ------------------------------------------------------------
      
      config.default_prog = { os.getenv("SHELL") or "/bin/bash", "-l" }
      
      config.set_environment_variables = {
        LANG = "en_US.UTF-8",
        LC_ALL = "en_US.UTF-8",
      }
      
      ------------------------------------------------------------
      -- Domains (SSH, unix, WSL)
      ------------------------------------------------------------
      
      config.ssh_domains = {
        {
           name = "athena0",
           remote_address = "athena0",
           username = "admin",
         },
      }
      
      config.unix_domains = {
        -- { name = "local" },
      }
      
      config.wsl_domains = {
        -- {
        --   name = "WSL:Ubuntu",
        --   distribution = "Ubuntu",
        -- },
      }
      
      ------------------------------------------------------------
      -- Misc quality-of-life
      ------------------------------------------------------------
      
      config.check_for_updates = false
      config.enable_kitty_graphics = true
      config.enable_kitty_keyboard = true
      
      config.window_close_confirmation = "AlwaysPrompt"  -- or "NeverPrompt"
      config.quit_when_all_windows_are_closed = false
      
      return config

    '';
  };
}
