{ pkgs, ... }:
{

  # NOTE: mise is a better alternative to asdf-vm
  #       to use this module, please remove asdf
  #       and import this into users's "default.nix" module.
  #       this is not necessary for admin as you won't need
  #       these tools on the home server box, but its useful
  #       for nix users on development machines

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
