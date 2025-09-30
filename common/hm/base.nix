{ pkgs
, username
, ...
}:
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  home.file = {

    ".config" = {
      enable = true;
      source = ../../stowed/.config;
      recursive = true;
    };

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

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    package = pkgs.nixVersions.nix_2_28;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      trusted-users = [ "${username}" ];
      http2 = false;
      allowed-users = [ "${username}" ];
      trusted-substituters = [ "https://cache.nixos.org/" ];
      substituters = [ "https://cache.nixos.org/" ];
      show-trace = true;
      auto-optimise-store = true;
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      fallback = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "recursive-nix"
      ];
    };
  };
}
