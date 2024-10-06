# Global Neovim config
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
  cfg = config.dream.program.neovim;
in
{
  options.dream.program.neovim = {
    enable = mkEnableOption "Enable program.neovim";
  };
  config = mkIf cfg.enable {
    programs.neovim.enable = true;
    programs.neovim.defaultEditor = true;
  };
}
