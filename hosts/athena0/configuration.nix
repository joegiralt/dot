# /etc/nixos/configuration.nix
{
  config,
  opts,
  pkgs,
  age,
  hostname,
  ...
}: {
  # Define overlays first (if any)
  # nixpkgs.overlays = [
  #   # No NVIDIA overlay needed
  # ];

  nixpkgs.config.cudaSupport = true;

  imports = [
    ./hardware-configuration.nix
    ../common/containers
    ../common/services
  ];

  # Secret definitions
  age.secrets = {
    athena0-admin-password.file = ../../secrets/athena0-admin-password.age;
    tailscale-auth-key.file = ../../secrets/tailscale-auth-key.age;
    mullvad-account-number.file = ../../secrets/mullvad-account-number.age;
    paperless-env.file = ../../secrets/paperless-env.age;
    plex-env.file = ../../secrets/plex-env.age;
    autokuma-env.file = ../../secrets/autokuma-env.age;
  };

  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Systemd targets
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Virtualization
  virtualisation.podman = {
    enable = true;
  };
  # Kernel sysctl
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = "1048576";
    "vm.swappiness" = 70;
    "vm.dirty_ratio" = 20;
    "vm.dirty_background_ratio" = 10;
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
    domain = ""; # TODO: get domain name!
    search = [opts.hostname];
    defaultGateway = {
      address = "192.168.1.1";
      interface = "enp90s0";
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
      allowedTCPPorts = [21 443 22];
      allowedUDPPorts = [21 443 22];
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

  # X11 and Desktop Environment
  services.xserver.enable = true;
  # services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Sound and Audio
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = false;
  services = {
    flatpak.enable = false;
    packagekit.enable = true;
    udisks2.enable = true;
    dbus.enable = true;
    printing.enable = false;

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
    passwordFile = config.age.secrets.athena0-admin-password.path;
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
    packages = with pkgs; [];
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
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };
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
    nvidia-container-toolkit
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

  # Nix Settings
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      warn-dirty = true;
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
    };
    package = pkgs.nixVersions.stable;
  };

  system.switch = {
    enable = false;
    enableNg = true;
  };

  system.copySystemConfiguration = false;

  # State Version
  system.stateVersion = "24.05";
}
