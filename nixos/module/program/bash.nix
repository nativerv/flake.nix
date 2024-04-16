{ ... }:
{
  config ? null,
  lib ? null,
  ...
}:
let 
  viMode = config.programs.bash.viMode;
in
{
  options.programs.bash.viMode = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to enable vi emulation in system's default bash shell";
  };
  config.programs.bash = {
    #promptInit = (builtins.readFile ./bash/bash_prompt.sh);
    #interactiveShellInit = (builtins.readFile ./bash/bashrc);
    interactiveShellInit = ''
      bind -x '"\C-l": clear'     
      printf '\033[2 q'

      # vi mode
      ${lib.optionalString viMode "set -o vi"}
      set show-mode-in-prompt on
      set vi-cmd-mode-string "\1\e[2 q\2"
      set vi-ins-mode-string "\1\e[6 q\2"
      bind -m vi-command 'Control-l: clear-screen'
      bind -m vi-insert 'Control-l": clear-screen'
    '';
    promptInit = ''
      PS1='\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\] '
    '';
    shellAliases = {
      lla = "ls -la";
      ll = "ls -l";
      la = "ls -a";
      nv = "nvim";
      renv = "unset __NIXOS_SET_ENVIRONMENT_DONE; exec $SHELL --login";
      sc = "systemctl";
      scu = "systemctl --user";
      jc = "journalctl";
      jcu = "journalctl --user";
      tm = "tmux";

      # Allow aliases with sudo
      sudo = "sudo ";
    };
  };
}
