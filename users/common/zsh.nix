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
    initExtra = ''
      unalias 9
      autoload -U down-line-or-beginning-search
      autoload -U up-line-or-beginning-search
      bindkey '^[[A' down-line-or-beginning-search
      bindkey '^[[A' up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      eval "$(atuin init zsh)"
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
