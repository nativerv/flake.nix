{
  self,
  ...
}:
{ ... }:
let
  name = "nrv";
  id = 1337010000;
in {
  users.groups.${name} = {
    gid = id;
  };
  users.users.${name} = {
    uid = id;
    group = "${name}";
    extraGroups = [
      "wheel"
      "part"
      "pool"
      "media"
      "vg"
      "steam"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/EhBI6sJb2yHbTkqhZiCzUrsLE6t+CZe7RhS22z7w5"
    ];

    initialPassword = "123";
    isNormalUser = true;
  };
}
