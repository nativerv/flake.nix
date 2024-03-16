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
{
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
}
