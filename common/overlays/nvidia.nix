_: _: prev:
let
  # Compat shim for nixGL against current nixpkgs:
  # 1. Strip the `kernel` arg (removed from nvidia generic.nix)
  # 2. Add vulkan ICD symlinks (renamed from nvidia_icd.x86_64.json → nvidia_icd.json)
  icdSymlinks = ''
    for out in $out ${placeholder "lib32"}; do
      d="$out/share/vulkan/icd.d"
      if [ -d "$d" ]; then
        for f in "$d"/nvidia_icd.json; do
          [ -f "$f" ] || continue
          ln -sf nvidia_icd.json "$d/nvidia_icd.x86_64.json"
          ln -sf nvidia_icd.json "$d/nvidia_icd.i686.json"
        done
      fi
    done
  '';

  wrappedNvidiaX11 = prev.lib.makeOverridable
    (args:
      (prev.linuxPackages.nvidia_x11.override
        (builtins.removeAttrs args [ "kernel" ])
      ).overrideAttrs (old: {
        postFixup = (old.postFixup or "") + icdSymlinks;
      })
    )
    { };
in
{
  nixgl = prev.nixgl.override {
    nvidiaURL = "https://us.download.nvidia.com/XFree86/Linux-x86_64";
    nvidiaVersion = "580.126.18";
    linuxPackages = prev.linuxPackages // {
      nvidia_x11 = wrappedNvidiaX11;
    };
  };
}
