{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    history = {
      ignoreDups = true;
      save = 1000000;
      size = 1000000;
    };
    shellAliases = {
      v = "vim";
    };
    initContent = ''
      unalias 9
      autoload -U down-line-or-beginning-search
      autoload -U up-line-or-beginning-search
      bindkey '^[[A' down-line-or-beginning-search
      bindkey '^[[A' up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      eval "$(atuin init zsh)"
      pod-logs() {
        local container_name=$1
        if [ -z "$container_name" ]; then
          echo "Please provide a container name."
          return 1
        fi
        podman ps -q --filter name="$container_name" | xargs -I {} podman logs {}
      }
      export LD_LIBRARY_PATH=/run/opengl-driver/lib
    '';
    oh-my-zsh = {
      enable = true;
      theme = "flazz";
      plugins = [
        "encode64"
        "git"
        "git-extras"
        "man"
        "nmap"
        "sudo"
        "vi-mode"
        "zsh-navigation-tools"
      ];
    };
  };
}
