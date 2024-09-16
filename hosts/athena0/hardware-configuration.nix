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


  environment.variables.LD_LIBRARY_PATH = "${pkgs.nvidiaPackages.stable}/lib:${pkgs.nvidiaPackages.stable}/lib64";

	hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    opengl.enable = true;
		graphics.enable = true;
		nvidia-container-toolkit = {
      enable = true;
      # mount-nvidia-executables = true;
    };
		nvidia = {

      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
      # of just the bare essentials.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of 
      # supported GPUs is at: 
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = false;

      # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
	};
}
