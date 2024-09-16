# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  opts,
  pkgs,
  age,
  hostname,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../common/containers
    ../common/services
    # "${pkgs.path}/nixos/modules/hardware/video/nvidia.nix"
    # "${pkgs.path}/nixos/modules/services/hardware/nvidia-container-toolkit/default.nix"
  ];

  # Secret defs
  age.secrets = {
    athena0-admin-password.file = ../../secrets/athena0-admin-password.age;
    tailscale-auth-key.file = ../../secrets/tailscale-auth-key.age;
    mullvad-account-number.file = ../../secrets/mullvad-account-number.age;
    paperless-env.file = ../../secrets/paperless-env.age;
    plex-env.file = ../../secrets/plex-env.age;
    autokuma-env.file = ../../secrets/autokuma-env.age;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  virtualisation.podman.enable = true;

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = "1048576";
    "vm.swappiness" = 70;
    "vm.dirty_ratio" = 20;
    "vm.dirty_background_ratio" = 10;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 196 * 1024;
      randomEncryption.enable = true;
    }
  ];

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
          IPV6 = {Enabled = false;};
          Settings = {AutoConnect = true;};
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
  services.xserver.videoDrivers = [ "nvidia" ];

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
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

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
    };
  };

  # nixpkgs.overlays = [
  #   (final: prev: {
  #     nvidia-container-toolkit = prev.nvidia-container-toolkit.overrideAttrs (oldAttrs: {
  #       postInstall = oldAttrs.postInstall or "" + ''
  #         wrapProgram $out/bin/nvidia-ctk \
  #           --set LD_LIBRARY_PATH "${config.boot.kernelPackages.nvidiaPackages.stable}/lib:${config.boot.kernelPackages.nvidiaPackages.stable}/lib64:$LD_LIBRARY_PATH"
  #       '';
  #     });
  #   })
  # ];

  nixpkgs.overlays = [
    (final: prev: {
      nvidiaPackages = prev.nvidiaPackages // {
        stable = prev.nvidiaPackages.stable.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            wrapProgram $out/bin/nvidia-ctk \
              --set LD_LIBRARY_PATH "${prev.nvidiaPackages.stable}/lib:${prev.nvidiaPackages.stable}/lib64:$LD_LIBRARY_PATH"
          '';
        });
      };
    })
  ];




  # List packages installed in system profile. To search, run:
  # $ nix search wget
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
    # nvidia-podman
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
    package = pkgs.nixFlakes;
  };

  system.switch = {
    enable = false;
    enableNg = true;
  };

  system.copySystemConfiguration = false;


  # NOTE: DO NOT CHANGE
  system.stateVersion = "24.05";
}
