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
          elixir = "latest";
          elm = "latest";
          erlang = "latest";
          gleam = "latest";
          golang = "latest";
          nodejs = "22.5.1";
          zig = "latest";
          yarn = "13.1.0";
        };
      };
    };
  };
}
