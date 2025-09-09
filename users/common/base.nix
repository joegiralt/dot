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
    ".tool-versions" = {
      enable = true;
      recursive = true;
      text =
        let
          versions = [
            {
              tool = "bun";
              version = "1.1.20";
            }
            {
              tool = "elixir";
              version = "1.17.2-otp-27";
            }
            {
              tool = "erlang";
              version = "27.0.1";
            }
            {
              tool = "golang";
              version = "1.22.5";
            }
            {
              tool = "nodejs";
              version = "22.5.1";
            }
            {
              tool = "ruby";
              version = "3.2.1";
            }
            {
              tool = "zig";
              version = "0.13.0";
            }
            {
              tool = "gleam";
              version = "1.3.2";
            }
          ];
        in
        builtins.concatStringsSep "\n" (builtins.map (v: "${v.tool} ${v.version}") versions);
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
        #     export GDK_SCALE=1.1
        #     export GDK_DPI_SCALE=1.1
        #     export QT_AUTO_SCREEN_SCALE_FACTOR=1.1
        #     export QT_SCALE_FACTOR=1.1
        #     export WINIT_X11_SCALE_FACTOR=1.1
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
      trusted-substituters = [ "${username}" ];
      show-trace = true;
      auto-optimise-store = true;
      fallback = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "recursive-nix"
      ];
    };
  };
}
