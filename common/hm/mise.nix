{ pkgs, ... }:
{
  home.packages = with pkgs; [
    mise
    usage
  ];

  home.file = {
    ".config/mise/config.toml" = {
      enable = true;
      recursive = true;
      source = (pkgs.formats.toml { }).generate "miseconf" {
        settings = {
          auto_install = false;
          not_found_auto_install = false;
          quiet = true;
        };
        tools = {
          bun = "latest";
          elixir = "1.19.5-otp-28";
          elm = "latest";
          erlang = "28.3.1";
          gleam = "latest";
          golang = "latest";
          nodejs = "22.5.1";
          ruby = "latest";
          zig = "latest";
          ocaml = "latest";
          julia = "latest";
          clojure = "latest";
          racket = "latest";
          python = "3.14.0";
        };
      };
    };
  };
}
