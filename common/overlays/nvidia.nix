_: _: prev:
let
  # Compat shim for nixGL against current nixpkgs:
  # 1. Strip the `kernel` arg (nixGL passes `kernel = null`, but the current
  #    nvidia generic.nix no longer accepts it).
  # 2. Add vulkan ICD symlinks (renamed from nvidia_icd.x86_64.json → nvidia_icd.json).
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

  # Wrap nvidia_x11's `.override` to silently drop `kernel`, plus wrap
  # `.overrideAttrs` so the patched `.override` survives nixGL's
  # `(nvidia_x11.override {}).overrideAttrs (...)` chain before its
  # `.override { libsOnly = true; kernel = null; }` call.
  patchNvidiaX11 = base:
    let
      addIcdShim = drv: drv.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + icdSymlinks;
      });
      cleanArgs = args:
        if builtins.isFunction args then
          (origArgs: builtins.removeAttrs (args origArgs) [ "kernel" ])
        else
          builtins.removeAttrs args [ "kernel" ];
    in
    (addIcdShim base) // {
      override = args: patchNvidiaX11 (base.override (cleanArgs args));
      overrideAttrs = f: patchNvidiaX11 (base.overrideAttrs f);
    };
in
{
  linuxPackages = prev.linuxPackages // {
    nvidia_x11 = patchNvidiaX11 prev.linuxPackages.nvidia_x11;
  };

  nixgl = prev.nixgl.override {
    nvidiaURL = "https://us.download.nvidia.com/XFree86/Linux-x86_64";
    nvidiaVersion = "580.126.18";
  };
}
