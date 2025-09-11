let
  admin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKb/dFPcj5XiylyXyPQH+SAZP6ce3PkdgVaLIPvnaL4g";
  josephgiralt = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICNLo4EXLOhYMQwi1cozZnSRbG7WnMyULHWzoag3wYff";
  carcosa = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFGf5kqPOJkt4VWH7yUhTxX3OhoL7a4g8wsMgIbBWuj7";

  users = [
    admin
    josephgiralt
    carcosa
  ];

  athena0 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDLasQWV2PpautvpHtLHGdEArpJdmBAFaBxQ+zbonBF5";

  systems = [
    athena0
  ];
in
{
  "secrets/athena0-admin-password.age" = {
    publicKeys = users ++ systems;
  };
  "secrets/tailscale-auth-key.age" = {
    publicKeys = users ++ systems;
  };
  "secrets/mullvad-account-number.age" = {
    publicKeys = users ++ systems;
  };
  "secrets/nextcloud-env.age" = {
    publicKeys = users ++ systems;
  };
  "secrets/paperless-env.age" = {
    publicKeys = users ++ systems;
  };
  "secrets/plex-env.age" = {
    publicKeys = users ++ systems;
  };
  "secrets/autokuma-env.age" = {
    publicKeys = users ++ systems;
  };
  "secrets/romms-env.age" = {
    publicKeys = users ++ systems;
  };
  "secrets/nextcloud-env.age" = {
    publicKeys = users ++ systems;
  };
}
