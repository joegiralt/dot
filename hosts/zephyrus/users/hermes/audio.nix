{ pkgs, ... }:
# ROG Zephyrus G14 (GA403WW) speaker volume fix.
#
# The internal speakers are split across the ALC285 codec and two CS35L56
# smart amps. PipeWire's hardware volume drives the codec's "Master" control,
# which only attenuates one speaker pair, so lowering the volume just turns
# down the bass. Using a software mixer scales the PCM stream itself, before
# it fans out to every speaker, and the hardware controls are pinned at 0 dB.
let
  card = "alsa_card.pci-0000_65_00.6";

  pinLevels = pkgs.writeShellScript "g14-speaker-levels" ''
    codec=$(${pkgs.gnugrep}/bin/grep -l 'ALC285' /proc/asound/card*/codec#* | ${pkgs.coreutils}/bin/head -n1)
    [ -n "$codec" ] || exit 0
    n=''${codec#/proc/asound/card}
    n=''${n%%/*}
    for ctl in Master Speaker PCM; do
      ${pkgs.alsa-utils}/bin/amixer -q -c "$n" set "$ctl" 100%
    done

    # The soft mixer applies card-wide, so mic gain is software-only too.
    # Pin the hardware capture gain (+6.75 dB, +30 dB boost on the internal
    # mic in use) so the mic slider at 100% gives a normal level.
    ${pkgs.alsa-utils}/bin/amixer -q -c "$n" set Capture 32 cap
    ${pkgs.alsa-utils}/bin/amixer -q -c "$n" set 'Internal Mic Boost',1 3
  '';
in
{
  xdg.configFile."wireplumber/wireplumber.conf.d/51-g14-soft-mixer.conf".text = ''
    monitor.alsa.rules = [
      {
        matches = [ { device.name = "${card}" } ]
        actions = { update-props = { api.alsa.soft-mixer = true } }
      }
    ]
  '';

  # Lower default latency for Bitwig and live monitoring. PipeWire's stock
  # quantum of 1024 @ 48 kHz is ~21 ms per buffer; 256 is ~5 ms. JACK clients
  # (Bitwig) can still ask for anything down to min-quantum. Allowing 44.1k
  # avoids resampling 44.1 kHz projects; rates only switch while idle.
  xdg.configFile."pipewire/pipewire.conf.d/92-low-latency.conf".text = ''
    context.properties = {
      default.clock.rate          = 48000
      default.clock.allowed-rates = [ 44100 48000 88200 96000 ]
      default.clock.quantum       = 256
      default.clock.min-quantum   = 32
      default.clock.max-quantum   = 2048
    }
  '';

  systemd.user.services.g14-speaker-levels = {
    Unit = {
      Description = "Pin G14 hardware speaker levels at 0 dB";
      After = [ "wireplumber.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = toString pinLevels;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
