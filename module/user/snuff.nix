{ lib, flake, ... }:
let
  name = "snuff";
in {
  users.users = {
    ${name} = {
      initialPassword = "123";
      isNormalUser = true;
      openssh.authorizedKeys.keyFiles = lib.ifUnlocked "${flake}/sus/ssh/${name}";
      extraGroups = [ "wheel" ];
    };
  };
}

