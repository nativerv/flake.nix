{
  self,
  flake,
  ...
}:
{
  lib,
  config,
  ...
}:
{
  programs.tmux = {
    enable = true;
    # This is all bullshit. Just reuse the file below
    # mouse = true;
    # prefix = "M-`";
    # keyMode = "vi";
    #
    # # Prevent tmux from spawning login shells
    # # set -g default-command "${SHELL}"
    #
    # # Remove delay when switching between Vim modes.
    # escapeTime = 0;
    #
    # # Scrollback history
    # historyLimit = 500000;
    #
    # # Enable color support inside of tmux
    # # `xterm-256color` => no (colored/any) undercurles in `nvim`
    # # `xterm-kitty`    => also works
    # terminal = "tmux-256color";

    # Enable undercurles support inside of tmux
    # set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
    # Enable colored underlines (and undercurles) support inside of tmux
    # set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

    # Import my old config for now - seems to work fine apart from plugins
    extraConfig = builtins.readFile "${flake}/home-manager/module/program/tmux/tmux.conf";
  };
}
