{ pkgs, config, ... }:
# asusctl CLI + ROG Control Center GUI for the user session.
#
# The asusd system daemon (systemd unit, udev rule, D-Bus policy) can't be
# managed by home-manager on Pop!_OS; `rake asusd:install` links the same
# store path into /etc. Run it after any change to the asusctl version.
{
  home.packages = [ (config.lib.nixGL.wrap pkgs.asusctl) ];
}
