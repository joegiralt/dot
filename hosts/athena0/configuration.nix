# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, opts, pkgs, hostname, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../common/containers
      ../common/services
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

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

  services.openssh = {
    enable    = true;
    allowSFTP = true;
    settings  = {
      PermitRootLogin              = "no";
      PasswordAuthentication       = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.admin = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPDPunXpUfzDT7xtjlqfsNKK2LmaCjKcAGiulHVPQBkQBuWcTXhO16vO+f5QMsNSS11cuKqQJ50x+m1vAn0olg4+0M+12fNvG0jBf1/LPR1oCO6Kjyt7UKURFrI+cHgaf7RqIWe9UuRNxgUhe81neWcOScQbnJKvosHwX8Y6hA0uMjFfz7m9FmleVd0QLVhPtfdNTao75raYz46CRKx6tkvgj8sbj522JIhNVoJ/t5tBQ5+kQVQxu1Qh+cteQ9/pskOYASwbuxOGUZ2Fw16edGIT6dk2t0tjpcEUcELfu6ROLncJvQC/GJdZr+L1yGldosxON2kFH1R3cEuvQI09dssLBcfhf7im6PO4eUqiWXDd2RQPOob2z81ONiTg7Uc4G/s+D4FVEsn+1xqf2htlOwbBQomjEpQ/bPNPHsrkNFszSO/3QmdASPTQS4baYn2R61p80c+C/h08oKqQa8txSBnsCJTsFO6c6B06Ulj31rAmFPjIuuzm9Iozml7tv0JoQlbJI7T1ewKUeMoRpVnSYWOeIiacG2V8e+w6XuDhk1UabsIOlnE+UCqt63iQHYey6cm4wpWrGE60ZfvS4rmkpIRIavZ3FCm9rT3h0MTcuIJrMTa+NjKgcWcIlj+vFs3P3OWrT1g+GlssRDWQ06x2oJgH+DlJ1RsnBzlGO0/7RgVQ=="
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICNLo4EXLOhYMQwi1cozZnSRbG7WnMyULHWzoag3wYff" 
    ];
    description = "Admin";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];  
  };

  # Install firefox.
  programs.firefox.enable = true;

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
  system.stateVersion = "24.05"; # Did you read the comment?

}
