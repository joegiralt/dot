# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config
, opts
, pkgs
, ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  age.secrets = {
    ponos0-admin-password.file = ../../secrets/ponos0-admin-password.age;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = "1048576";
    "vm.swappiness" = 70;
    "vm.dirty_ratio" = 20;
    "vm.dirty_background_ratio" = 10;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 128 * 1024;
      randomEncryption.enable = true;
    }
  ];

  # Enable networking
  networking = {
    hostName = opts.hostname;
    domain = opts.hostname;
    search = [ opts.hostname ];
    defaultGateway = {
      address = "192.168.1.1";
      interface = "eno1";
    };
    wireless = {
      iwd = {
        enable = true;
        settings = {
          IPV6 = { Enabled = false; };
          Settings = { AutoConnect = true; };
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
      allowedTCPPorts = [ 21 443 22 ];
      allowedUDPPorts = [ 21 443 22 ];
    };
  };

  # Set your time zone.
  time.timeZone = opts.timeZone;

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.openssh.enable = true;
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.admin = {
    passwordFile = config.age.secrets.ponos0-admin-password.path;

    isNormalUser = true;
    description = "Admin";
    openssh.authorizedKeys.keys = with opts.publicKeys; [
      carcosa-ed25519
      macbook-ed25519
      spare-macbook-ed25519
    ];
    shell = pkgs.zsh;
    extraGroups = [
      "audio"
      "bluetooth"
      "disk"
      "docker"
      "lp"
      "networkmanager"
      "sshd"
      "video"
      "wheel"
    ];
    packages = with pkgs; [ ];
  };

  programs = {
    firefox.enable = true;
    zsh.enable = true;
    nix-ld.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alsa-utils
    # awscli2
    libmysqlclient
    libsndfile
    libmysqlclient
    unixODBC
    bcc
    busybox
    clang
    cmake
    cryptsetup
    curlFull
    dhcpcd
    direnv
    docker_26
    docker-compose
    fasm-bin
    fastfetch
    ffmpeg
    gcc
    gh
    git
    git-crypt
    gnumake
    home-manager
    hwinfo
    icecast
    iwd
    kexec-tools
    lshw
    libffi
    man
    mosh
    mullvad
    mullvad-vpn
    netcat-gnu
    nvme-cli
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
    zlib
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions;
        [
          bbenoist.nix
          ms-python.python
          ms-azuretools.vscode-docker
          ms-vscode-remote.remote-ssh
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "remote-ssh-edit";
            publisher = "ms-vscode-remote";
            version = "0.47.2";
            sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
          }
        ];
    })
  ];

  environment.variables = {
    LD_LIBRARY_PATH = "${pkgs.curlFull.out}/lib";
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      warn-dirty = true;
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    package = pkgs.nixFlakes;
  };

  system.switch = {
    enable = false;
    enableNg = true;
  };

  system.copySystemConfiguration = false;
  system.stateVersion = "24.05"; # Did you read the comment?

  services.tailscale.enable = true;

  virtualisation.docker.enable = true;
}
