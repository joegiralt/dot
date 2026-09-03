{ pkgs, config, ... }:
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;

    # Ghostty is a GPU-accelerated terminal, and these hosts are
    # generic-Linux (not NixOS), so it needs the nixGL wrapper to find a
    # usable libGL — same treatment as wezterm.nix and the GUI packages in
    # the per-user configs. `wrap` (mesa) rather than `wrapOffload`
    # (nvidia): a terminal has no reason to spin up the discrete GPU.
    package = config.lib.nixGL.wrap pkgs.ghostty;

    installVimSyntax = true;
    installBatSyntax = true;

    # Palette lifted from wezterm.nix's "XY-Zed" scheme so both terminals
    # render identically.
    themes.xy-zed = {
      background = "121212";
      foreground = "f7f7f8";
      cursor-color = "8BEF9A";
      cursor-text = "121212";
      selection-background = "8BEF9A";
      selection-foreground = "121212";
      palette = [
        "0=#1e2025"
        "1=#f82871"
        "2=#8BEF9A"
        "3=#fee56c"
        "4=#10a793"
        "5=#c74cec"
        "6=#08e7c5"
        "7=#f7f7f8"
        "8=#40434c"
        "9=#8e0f3a"
        "10=#457c38"
        "11=#958334"
        "12=#1a5148"
        "13=#682681"
        "14=#008169"
        "15=#f7f7f8"
      ];
    };

    settings = {
      theme = "xy-zed";

      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;

      window-padding-x = 4;
      window-padding-y = 2;
      window-decoration = "none";

      cursor-style = "bar";
      cursor-style-blink = false;

      scrollback-limit = 10000000;

      copy-on-select = "clipboard";
      mouse-hide-while-typing = true;

      # wezterm.nix disables the audible bell; match it.
      confirm-close-surface = true;

      keybind = [
        "ctrl+shift+t=new_tab"
        "ctrl+shift+w=close_surface"
        "ctrl+shift+backslash=new_split:right"
        "ctrl+shift+minus=new_split:down"
        "ctrl+alt+h=goto_split:left"
        "ctrl+alt+l=goto_split:right"
        "ctrl+alt+k=goto_split:up"
        "ctrl+alt+j=goto_split:down"
        "ctrl+shift+r=reload_config"
      ];
    };
  };
}
