{ self, lib, flake, ... }:
let
  name = "nrv";
in {
  users.users = {
    ${name} = {
      initialPassword = "123";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/EhBI6sJb2yHbTkqhZiCzUrsLE6t+CZe7RhS22z7w5"
      ];
      extraGroups = [ "wheel" ];
    };
  };
}
