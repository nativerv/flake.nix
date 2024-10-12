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
  cfg = config.dream.archetype.remote;
in
{
  options.dream.archetype.remote = {
    enable = mkEnableOption "Enable archetype.remote - this machine will be remotely logged into";
  };
  config = mkIf cfg.enable {
    dream.service.sshd.enable = true;
    environment.systemPackages = with pkgs; [
      # TODO: maybe this is no place for rsync/by default at least?
      rsync
    ];
  };
}
