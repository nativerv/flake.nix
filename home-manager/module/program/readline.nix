{
  self,
  flake,
  ...
}:
{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with self.lib;
{
  programs.readline = {
    enable = true;
  };
  systemd.user.sessionVariables.INPUTRC = "${config.xdg.configHome}/readline/inputrc";
  xdg.configFile."readline/inputrc".source = ./readline/inputrc;
  # FIXME: .haskeline home dotfile
  home.file.".haskeline".source = ./readline/haskeline;
}
