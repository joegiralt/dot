let
  admin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKb/dFPcj5XiylyXyPQH+SAZP6ce3PkdgVaLIPvnaL4g";
  josephgiralt = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICNLo4EXLOhYMQwi1cozZnSRbG7WnMyULHWzoag3wYff";
  users = [ admin josephgiralt ];

  athena0 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDLasQWV2PpautvpHtLHGdEArpJdmBAFaBxQ+zbonBF5";
  systems = [ athena0 ];
in
{
  "athena0-admin-password.age" = { publicKeys = users ++ systems; };
  "tailscale-auth-key.age" = { publicKeys = users ++ systems; };
  "mullvad-account-number.age" = { publicKeys = users ++ systems; };
  "nextcloud-env.age" = { publicKeys = users ++ systems; };
  "paperless-env.age" = { publicKeys = users ++ systems; };
}
