{
  inputs ? null,
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
  cfg = config.dream.program.nix-index;
in
{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];
  options.dream.program.nix-index = {
    enable = mkEnableOption "Enable program.nix-index";
  };
  config = mkIf cfg.enable {
    # programs.nix-index.enable = true;
    # programs.nix-index.package = ;
    programs.command-not-found.enable = false;
    programs.nix-index.enableBashIntegration = false;
    programs.nix-index.enableZshIntegration = false;
    programs.nix-index.enableFishIntegration = false;
  };
}
