{
  config,
  opts,
  pkgs,
  system,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../common/os/containers
    ../../common/os/services
    ../../common/secmap.nix
  ];

  # Bootloader configuration
  boot = {
    kernel.sysctl = {
      "fs.inotify.max_user_watches" = "1048576";
      "vm.swappiness" = 70;
      "vm.dirty_ratio" = 20;
      "vm.dirty_background_ratio" = 10;
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  environment.etc = {
    "avahi/avahi-daemon.conf" = {
      enable = true;
      text = "";
    };
  };
  # Systemd targets
  systemd = {
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  # Virtualization
  virtualisation.podman = {
    enable = true;
  };

  # Swap Devices
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 196 * 1024;
      randomEncryption.enable = true;
    }
  ];

  # Networking
  networking = {
    hostName = opts.hostname;
    domain = "nothing.ltd";
    search = [ opts.hostname ];
    defaultGateway = {
      address = "192.168.1.1";
      interface = "enp90s0";
    };
    wireless = {
      iwd = {
        enable = true;
        settings = {
          IPV6 = {
            Enabled = false;
          };
          Settings = {
            AutoConnect = true;
          };
        };
      };
    };
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      insertNameservers = opts.nameservers;
    };
    nameservers = pkgs.lib.mkForce opts.nameservers;
    enableIPv6 = false;
    firewall = {
      enable = true;
      allowPing = false;
      allowedTCPPorts = [
        21
        443
        22
      ];
      allowedUDPPorts = [
        21
        443
        22
      ];
    };
  };

  # Timezone
  time.timeZone = opts.timeZone;

  # Internationalization
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = opts.locale;
    LC_IDENTIFICATION = opts.locale;
    LC_MEASUREMENT = opts.locale;
    LC_MONETARY = opts.locale;
    LC_NAME = opts.locale;
    LC_NUMERIC = opts.locale;
    LC_PAPER = opts.locale;
    LC_TELEPHONE = opts.locale;
    LC_TIME = opts.locale;
  };

  # Sound and Audio
  security = {
    rtkit.enable = true;
    sudo.wheelNeedsPassword = false;
  };
  services = {
    displayManager.gdm.enable = false;
    desktopManager.gnome.enable = false;
    xserver = {
      enable = false;
      xkb.layout = "us";
      videoDrivers = [ "nvidia" ];
    };
    pulseaudio.enable = false;
    flatpak.enable = false;
    packagekit.enable = true;
    udisks2.enable = true;
    dbus.enable = true;
    printing.enable = false;
    avahi.enable = false;

    openvscode-server = {
      enable = true;
      package = pkgs.openvscode-server;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      #jack.enable = true; # If you want to use JACK applications, uncomment this
    };

    openssh = {
      enable = true;
      allowSFTP = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = false;
      };
    };
  };

  # User Accounts
  users.users.admin = {
    # FIX: THIS OPTION IS DEPRECATED, USE `hashedPassword` instead.
    #      THE `hashedPassword` can be generated using the `mkpasswd` command on nixos
    hashedPasswordFile = config.age.secrets.athena0-admin-password.path;
    isNormalUser = true;
    openssh.authorizedKeys.keys = with opts.publicKeys; [
      carcosa-ed25519
      macbook-ed25519
      spare-macbook-ed25519
    ];
    shell = pkgs.zsh;
    description = "Admin";
    extraGroups = [
      "audio"
      "bluetooth"
      "disk"
      "docker"
      "lp"
      "networkmanager"
      "ntfy-sh"
      "scanner"
      "sshd"
      "vboxusers"
      "video"
      "wheel"
    ];
    packages = [ ];
  };

  # Programs
  programs = {
    firefox.enable = true;
    zsh.enable = true;
    mtr.enable = true;
    mosh.enable = true;
    nix-ld.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Nixpkgs Configuration

  nixpkgs = {
    config = {
      allowUnfree = true;
      cudaSupport = true;
      nvidia.acceptLicense = true;
    };
    overlays = import ../../common/overlays { inherit inputs; };
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    alsa-utils
    bcc
    busybox
    clang
    cmake
    cryptsetup
    curl
    dhcpcd
    fasm-bin
    fastfetch
    ffmpeg
    git
    git-crypt
    gnumake
    home-manager
    hwinfo
    icecast
    iwd
    kexec-tools
    lshw
    man
    mosh
    mullvad
    mullvad-vpn
    netcat-gnu
    openresolv
    openssl
    openvpn
    ouch
    p7zip
    parallel
    parted
    pciutils
    progress
    sshfs
    strace
    traceroute
    unzip
    zfs
    zip
    zmap
    zsh
  ];

  # Nix Settings
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      trusted-users = [
        "root"
        "admin"
      ];
      warn-dirty = true;
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [ "https://cache.nixos.org/" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      trusted-substituters = [ "https://cache.nixos.org" ];
    };
    package = pkgs.nixVersions.stable;
  };

  system = {
    switch = {
      enable = true;
    };
    stateVersion = "24.05";
    copySystemConfiguration = false;
    # NOTE: joe, this might be what is actaully causing the issue
    activationScripts.fixHomeOwnership = {
      text = ''
        # set owners + perms (no -R, on purpose)
        chown root:root /
        chmod 0755 /

        chown root:root /home
        chmod 0755 /home

        # adjust to your login/group
        if [ -d /home/admin ]; then
          chown admin:users /home/admin
          chmod 0700 /home/admin
        fi
      '';
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit system inputs;
      opts = opts // (import ./users/admin/opts.nix);
      username = "admin";
      host = "athena0";
    };
    users = {
      admin =
        { ... }:
        {
          imports = [
            inputs.agenix.homeManagerModules.age
            ./users/admin
          ];
        };
    };
  };
}
