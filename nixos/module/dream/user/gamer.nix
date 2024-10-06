{
  self,
  ...
}:
{
  lib,
  pkgs,
  config,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  # TODO: infer user name from file name
  name = "gamer";
  id = 1337010001;
  cfg = config.dream.user.gamer;
  cfgUser = config.users.users.${name};
in {
  options.dream.user.gamer = {
    enable = mkEnableOption "Enable user.gamer";
  };
  config = mkIf cfg.enable {
    users.groups.${name} = {
      gid = id;
    };
    users.users.${name} = {
      uid = id;
      group = "${name}";
      createHome = true;
      extraGroups = [
        "pool"
        "steam"
      ];

      # FIXME(dream: options): maybe do some conditional 'if sops enabled' logic there?
      # Or is that fine that passwords/secrets are set per-system?
      # Probably. Worth anyway to replace it with hashed default,
      # and move it to shared `config/`.
      initialPassword = lib.mkIf (cfgUser.hashedPasswordFile == null) "123";
      isNormalUser = true;
    };
  };
}
