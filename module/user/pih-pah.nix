{ config, lib, flake, ... }:
{
  users.users = {
    pih-pah = {
      initialPassword = "123";
      isNormalUser = true;
      openssh.authorizedKeys.keyFiles =
        lib.ifUnlocked "${flake}/sus/ssh/nrv"
        ++ lib.ifUnlocked "${flake}/sus/ssh/yukkop"
        ++ lib.ifUnlocked "${flake}/sus/ssh/snuff"
      ;
      home = "/srv/pih-pah";
      extraGroups = ["pih-pah"];
    };
  };
}
