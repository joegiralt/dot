_: final: prev:
let
  version = "6.5.0";
in
{
  # asusctl moved to github:OpenGamingCollective/asusctl and nixpkgs lags
  # behind. Bump it until nixpkgs catches up, then this falls through.
  asusctl =
    if prev.lib.versionOlder prev.asusctl.version version then
      prev.asusctl.overrideAttrs (
        finalAttrs: _: {
          inherit version;

          src = final.fetchFromGitHub {
            owner = "OpenGamingCollective";
            repo = "asusctl";
            tag = version;
            hash = "sha256-UTs9LF2EKUj5vxG0hc9V4DvCFMbyYgvA645ClxnE3WM=";
          };

          cargoDeps = final.rustPlatform.fetchCargoVendor {
            inherit (finalAttrs) src;
            name = "asusctl-${version}";
            hash = "sha256-Kujj8gQ5qsEv2iLO3T1JoK0E2q0ByOhxpuN942EvB7Q=";
          };
        }
      )
    else
      prev.asusctl;
}
