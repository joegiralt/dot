{
  username,
  ...
}:
{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Set your preferences here
      history = {
        path = "/home/${username}/.local/share/atuin/history.db";
      };
      sync = {
        # Configure automatic synchronization
        enabled = false;
        address = "https://atuin.nothing.ltd";
        # auth_key = "your-auth-key-here"; # Your authentication key
      };
    };
  };
}
