# hardware-configuration.nix
# Minisforum MS-01 
# w/ NVIDIA RTX 2000 / 2000E Ada Generation
# w/ 12th Gen Intel(R) Core(TM) i5-12600H (16) @ 4.50 GHz

{
  config,
  opts,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.kernelParams = ["nohibernate"];
  boot.extraModulePackages = [];

  boot.blacklistedKernelModules = [ "nouveau" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c2507f11-d97b-4ceb-8bc3-15e7f5b8953b";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6111-BE56";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/5dde3f85-e5b9-4286-a180-eade534798bb";
    fsType = "ext4";
  };

  fileSystems."/mnt/data2" = {
    device = "/dev/disk/by-uuid/86ab48f6-2469-4eb2-afe1-88daf1bd9a11";
    fsType = "ext4";
  };

  swapDevices = [];

  networking = {
    useDHCP = lib.mkDefault false;
    hostId = "0ec79991";
    # consider moving to systemd.network.netdev
    interfaces = {
      enp90s0 = {
        useDHCP = lib.mkDefault true;
        ipv4 = {
          addresses = [
            {
              address = opts.lanAddress;
              prefixLength = 24;
            }
          ];
        };
      };
      wlan0 = {
        useDHCP = lib.mkDefault true;
      };
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    opengl.enable = true;
    graphics.enable = true;

    # Enable NVIDIA support
    nvidia = {
      # enable = true;
      modesetting.enable = true;

      # Power Management Settings
      powerManagement.enable = false;
      powerManagement.finegrained = false;

      # Open Source Kernel Module
      open = true;

      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "525.116.04";
        sha256_64bit = "sha256-hhDsgkR8/3LLXxizZX7ppjSlFRZiuK2QHrgfTE+2F/4=";
        sha256_aarch64 = "sha256-k7k22z5PYZdBVfuYXVcl9SFUMqZmK4qyxoRwlYyRdgU=";
        openSha256 = "sha256-dktHCoESqoNfu5M73aY5MQGROlZawZwzBqs3RkOyfoQ=";
        settingsSha256 = "sha256-qNjfsT9NGV151EHnG4fgBonVFSKc4yFEVomtXg9uYD4=";
        persistencedSha256 = "sha256-ci86XGlno6DbHw6rkVSzBpopaapfJvk0+lHcR4LDq50=";

        ibtSupport = true;
      };

      # NVIDIA Settings Menu
      nvidiaSettings = true;
    };

    # NVIDIA Container Toolkit
    nvidia-container-toolkit = {
      enable = true;
      mount-nvidia-executables = true;
    };
  };
}
