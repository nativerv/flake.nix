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
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.program.readline;
in
{
  options.dream.program.readline = {
    enable = mkEnableOption "Enable program.readline";
  };
  config = mkIf cfg.enable {
    programs.readline = {
      enable = true;
    };
    systemd.user.sessionVariables.INPUTRC = "${config.xdg.configHome}/readline/inputrc";
    xdg.configFile."readline/inputrc".source = ./readline/inputrc;
    # FIXME: .haskeline home dotfile
    home.file.".haskeline".source = ./readline/haskeline;
  };
}
