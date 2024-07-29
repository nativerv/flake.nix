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
  name = "nrv";
  id = 1337010000;
  cfg = config.users.users.${name};
in {
  config = {
    users.groups.${name} = {
      gid = id;
    };
    users.users.${name} = {
      uid = id;
      group = "${name}";
      createHome = true;
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

      initialPassword = lib.mkIf (cfg.hashedPasswordFile == null) "123";
      isNormalUser = true;
    };
    
    # NOTE: mitigate permission denied /etc/ssh/authorized_keys.d/nrv
    virtualisation.vmVariant.system.userActivationScripts.nrv-ssh-authorized-keys.text = ''
      mkdir -p "''${HOME}/.ssh"
      cp -f ${pkgs.writeText "nrv-ssh-authorized-keys" "${lib.concatStringsSep "\n" cfg.openssh.authorizedKeys.keys}"} "''${HOME}/.ssh/authorized_keys"
    '';
  };
}
