{
  pkgs,
  username,
  ...
}:
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  home.file = {
    ".profile" = {
      enable = true;
      recursive = false;
      target = ".profile";
      executable = true;
      text = ''
        export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"
        export NIX_LD=/run/current-system/sw/share/nix-ld/lib/ld.so
      '';
    };

    ".xsession" = {
      enable = true;
      executable = true;
      recursive = true;
      text = ''
        export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"
      '';
    };
  };

  programs = {
    home-manager.enable = true;
    htop.enable = true;
    # ssh.startAgent = true;
  };

  systemd.user = {
    enable = true;
    startServices = "sd-switch";
  };

  news.display = "silent";
}
