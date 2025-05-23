{
  self ? null,
  ...
}:
{
  config ? null,
  lib ? null,
  pkgs ? null,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.archetype.interactive;
in
{
  options.dream.archetype.interactive = {
    enable = mkEnableOption "Enable archetype.interactive - humas will log in to this machine";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      file
      rsync
      p7zip
      curl
      git # TODO: does git belong here?
    ];
    dream.program = {
      # TODO(dream: normie): 
      bash.enable = true;

      sudo.enable = true;
      htop.enable = true;
    };
  };
}
