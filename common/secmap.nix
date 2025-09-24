{ ... }:
{
  age.secrets = {
    athena0-admin-password.file = ../secrets/athena0-admin-password.age;
    autokuma-env.file = ../secrets/autokuma-env.age;
    mullvad-account-number.file = ../secrets/mullvad-account-number.age;
    nextcloud-env.file = ../secrets/nextcloud-env.age;
    paperless-env.file = ../secrets/paperless-env.age;
    plex-env.file = ../secrets/plex-env.age;
    romm_env.file = ../secrets/romms-env.age;
    tailscale-auth-key.file = ../secrets/tailscale-auth-key.age;
  };
}
