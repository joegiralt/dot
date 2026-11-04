# hardware-configuration.nix
# Minisforum MS-01
# w/ NVIDIA RTX 2000 / 2000E Ada Generation
# w/ 12th Gen Intel(R) Core(TM) i5-12600H (16) @ 4.50 GHz

{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    kernelParams = [ "nohibernate" ];
    extraModulePackages = [ ];
    blacklistedKernelModules = [ "nouveau" ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/c2507f11-d97b-4ceb-8bc3-15e7f5b8953b";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/6111-BE56";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
    "/mnt/data" = {
      device = "/dev/disk/by-uuid/5dde3f85-e5b9-4286-a180-eade534798bb";
      fsType = "ext4";
    };
    "/mnt/data2" = {
      device = "/dev/disk/by-uuid/86ab48f6-2469-4eb2-afe1-88daf1bd9a11";
      fsType = "ext4";
    };
  };

  swapDevices = [ ];

  networking = {
    useDHCP = lib.mkDefault false;
    hostId = "0ec79991";
    # LAN (enp91s0) is DHCP via NetworkManager; 192.168.1.32 comes from the
    # router's reservation. The old static block named enp90s0, which no
    # longer exists on this box, so it was never applied.
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware = {
    cpu.intel.updateMicrocode = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [ vulkan-loader ];
      extraPackages32 = with pkgs.pkgsi686Linux; [ vulkan-loader ];
    };

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = true; # NVIDIA-recommended for Turing+ (Ada here)
      nvidiaSettings = true;
      nvidiaPersistenced = true;
    };

    # NVIDIA Container Toolkit
    nvidia-container-toolkit = {
      enable = true;
      mount-nvidia-executables = true;
    };
  };

  systemd.services.nvidia-container-toolkit-cdi-generator.environment.LD_LIBRARY_PATH =
    "${pkgs.lib.getLib config.hardware.nvidia.package}/lib";

  environment.etc."cdi/nvidia-container-toolkit.json".source =
    "/run/cdi/nvidia-container-toolkit.json";
}
