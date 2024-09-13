let
  admin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKb/dFPcj5XiylyXyPQH+SAZP6ce3PkdgVaLIPvnaL4g";
  josephgiralt = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICNLo4EXLOhYMQwi1cozZnSRbG7WnMyULHWzoag3wYff";
  users = [ admin josephgiralt ];

  athena0 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDLasQWV2PpautvpHtLHGdEArpJdmBAFaBxQ+zbonBF5";
  ponos0 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIwAevvfcLWoxd2libwOZzOEh3wTI7+BzeHD39hRJ+o7";

  personal-systems = [ athena0 ];
  shared-systems = [ athena0 ponos0 ];
  work-systems = [ ponos0 ];
in
{
  "athena0-admin-password.age" = { publicKeys = users ++ personal-systems; };
  "tailscale-auth-key.age" = { publicKeys = users ++ shared-systems; };
  "mullvad-account-number.age" = { publicKeys = users ++ personal-systems; };
  "nextcloud-env.age" = { publicKeys = users ++ personal-systems; };
  "paperless-env.age" = { publicKeys = users ++ personal-systems; };
  "plex-env.age" = { publicKeys = users ++ personal-systems; };
  "autokuma-env.age" = { publicKeys = users ++ personal-systems; };
  "ponos0-admin-password.age" = { publicKeys = users ++ work-systems; };
}
