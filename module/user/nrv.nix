{ self, lib, flake, ... }:
let
  name = "nrv";
in {
  users.users = {
    ${name} = {
      initialPassword = "123";
      isNormalUser = true;
      openssh.authorizedKeys.keyFiles = self.lib.ifUnlocked "${flake}/sus/ssh/${name}";
      extraGroups = [ "wheel" ];
    };
  };
}
