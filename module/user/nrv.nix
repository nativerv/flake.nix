{ ... }:
{
  users.users = {
    nrv = {
      initialPassword = "123";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
      ];
      extraGroups = [ "wheel" ];
    };
  };
}
