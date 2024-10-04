{
  self ? null,
  ...
}:
{
  config ? null,
  lib ? null,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.program.git;
in
{
  options.dream.program.git = {
    enable = mkEnableOption "Enable program.git";
  };
  config = mkIf cfg.enable {
    programs.git.enable = true;
  };
}
