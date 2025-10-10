_: {
  systemd.oomd = {
    enable = true;
    enableSystemSlice = true;
    enableRootSlice = false;
    enableUserSlices = true;
    settings.OOM = {
      DefaultMemoryPressureDurationSec = "30s";
      DefaultMemoryPressureLimit = "60%";
      SwapUsedLimit = "90%";
    };
  };
}
