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
let
  # TODO: infer user name from file name
  name = "gamer";
  id = 1337010001;
  cfg = config.users.users.${name};
in {
  config = {
    users.groups.${name} = {
      gid = id;
    };
    users.users.${name} = {
      uid = id;
      group = "${name}";
      extraGroups = [
        "pool"
        "steam"
      ];

      # TODO: maybe do some conditional 'if sops enabled' logic there?
      #       Or is that fine that passwords/secrets are set per-system?
      #       Probably. Worth anyway to replace it with hashed default,
      #       and move it to shared `config/`.
      initialPassword = lib.mkIf (cfg.hashedPasswordFile == null) "123";
      isNormalUser = true;
    };
  };
}
