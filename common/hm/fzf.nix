{ pkgs, ... }:
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    # atuin owns Ctrl-R; fzf keeps Ctrl-T and Alt-C
    historyWidget.command = "";
  };
}
