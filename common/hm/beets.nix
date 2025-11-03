{
  opts,
  username,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    beets
  ];

  systemd.user.tmpfiles.settings.beets = {
    purgeOnChange = false;
    rules = {
      "/home/${username}/.config/beets".d = {
        mode = "0755";
        user = opts.adminUID;
        group = opts.adminGID;
        age = "-";
      };
    };
  };

  home.file = {
    ".config/beets/config.yaml" = {
      target = ".config/beets/config.yaml";
      executable = false;
      recursive = false;
      enable = true;
      text = ''
        directory: ${opts.paths.music}
        library: /home/${username}/.config/beets/musiclibrary.db
        plugins: fetchart lyrics lastgenre
        import:
          move: yes
      '';
    };
  };
}
