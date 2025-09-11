{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;

    # new-style API
    profiles.default = {
      enable = true;

      # combine official nixpkgs extensions with marketplace ones
      extensions =
        (with pkgs.vscode-extensions; [
          bbenoist.nix
          ms-python.python
          ms-azuretools.vscode-docker
          ms-vscode-remote.remote-ssh
        ])
        ++ (pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "remote-ssh-edit";
            publisher = "ms-vscode-remote";
            version = "0.47.2";
            sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
          }
        ]);

      # optional: drop settings here
      userSettings = {
        "editor.formatOnSave" = true;
        # "terminal.integrated.defaultProfile.linux" = "zsh";
      };

      # optional: lock UI state to the profile (prevents code from writing outside HM)
      # mutableExtensionsDir = false;
    };
  };
}
