{
  self ? null,
  flake ? null,
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
  cfg = config.dream.user.pih-pah;
in
{
  options.dream.user.pih-pah = {
    enable = mkEnableOption "Enable user.pih-pah";
  };
  config = mkIf cfg.enable {
    users.users = {
      pih-pah = {
        initialPassword = "123";
        isNormalUser = true;
        openssh.authorizedKeys.keyFiles =
          self.lib.ifUnlocked "${flake}/sus/ssh/nrv"
          ++ self.lib.ifUnlocked "${flake}/sus/ssh/yukkop"
          ++ self.lib.ifUnlocked "${flake}/sus/ssh/snuff";
        home = "/srv/pih-pah";
        extraGroups = ["pih-pah"];
      };
    };
  };
}
