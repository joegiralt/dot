{
  hostname = "athena0";
  lanAddress = "192.168.1.32";
  timeZone = "Europe/Madrid";
  adminUID = "1000";
  adminGID = "100";
  locale = "en_US.UTF-8";
  nameservers = [
    "9.9.9.9"         # Quad9
    "149.112.112.112" # Quad9
    "194.242.2.5"     # Mullvad
  ];
}
