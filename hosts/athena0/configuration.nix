# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, opts, pkgs, hostname, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../common/containers
      ../common/services
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  networking = {
    hostName = opts.hostname;
    domain = ""; # TODO: get domain name!
    search = [ opts.hostname ];
    defaultGateway = {
      address = "192.168.1.1";
      interface = "enp89s0";
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
  services.xserver.enable = false;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = false;

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

  services.openssh = {
    enable = true;
    allowSFTP = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.admin = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = with opts.publicKeys; [
      macbook-ed25519
      macbook-rsa
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
    packages = with pkgs; [ ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Enables Zsh
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
      ];
    })
  ];

  # NOTE: DO NOT CHANGE
  system.stateVersion = "24.05";

}
