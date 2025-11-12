{ config, pkgs, ... }:
{

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "flazz";
      plugins = [ "git" ];
    };

    history = {
      size = 20000;
      save = 20000;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      share = true;
      extended = true;
    };

    initContent = ''
      setopt histignoredups sharehistory
      setopt nobeep
      bindkey -e
      eval "$(atuin init zsh)"
      if [[ $- == *i* ]] && [ -t 1 ]; then
        command -v fastfetch >/dev/null && fastfetch
      fi
    '';
  };
}
