{ self,  lib, flake, ... }:
let
  name = "yukkop";
in {
  users.users = {
    ${name} = {
      initialPassword = "kk";
      isNormalUser = true;
      openssh.authorizedKeys.keyFiles = self.lib.ifUnlocked "${flake}/sus/ssh/${name}";
      extraGroups = [ "wheel" ];
    };
  };
}
