{
  pkgs,
  username,
  ...
}: {
  programs.atuin = {
    enable = true;
    settings = {
      # Set your preferences here
      history = {
        path = "/home/${username}/.local/share/atuin/history.db";
      };
      sync = {
        # Configure automatic synchronization
        enabled = false;
        # address = "https://sync.youratuinserver.com"; # Change this to your Atuin server address
        # auth_key = "your-auth-key-here"; # Your authentication key
      };
    };
  };
}
