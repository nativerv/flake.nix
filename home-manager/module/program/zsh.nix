{
  self,
  ...
}:
{
  lib,
  config,
  ...
}:
with self.lib;
with lib;
let
  homeDir = config.home.homeDirectory;
  configHome = config.xdg.configHome;

  histSize = (pow 2 63) - 1;
in {
  programs.zsh = {
    enable = true;

    dotDir =
      if hasPrefix homeDir configHome
      then "${removePrefix homeDir configHome}/zsh"
      else "";

    history = {
      size = histSize;
      save = histSize;
      path = "${config.xdg.stateHome}/zsh/history";
      extended = true;
    };
  };
}
