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
with builtins;
with lib;
with self.lib;
let
  # TODO: infer user name from file name
  name = "nrv";
  id = 1337010000;
  cfg = config.dream.user.nrv;
  cfgUser = config.users.users.${name};
in {
  options.dream.user.nrv = {
    enable = mkEnableOption "Enable user.nrv";
  };
  config = mkIf cfg.enable {
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
        "vm"
      ];

      shell = pkgs.zsh;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/EhBI6sJb2yHbTkqhZiCzUrsLE6t+CZe7RhS22z7w5"
      ];

      # FIXME(dream: options): maybe do some conditional 'if sops enabled' logic there?
      # Or is that fine that passwords/secrets are set per-system?
      # Probably. Worth anyway to replace it with hashed default,
      # and move it to shared `config/`.
      initialPassword = lib.mkIf (cfgUser.hashedPasswordFile == null) "123";
      isNormalUser = true;
    };
    
    # NOTE: mitigate permission denied /etc/ssh/authorized_keys.d/nrv
    virtualisation.vmVariant.system.userActivationScripts.nrv-ssh-authorized-keys.text = ''
      mkdir -p "''${HOME}/.ssh"
      cp -f ${pkgs.writeText "nrv-ssh-authorized-keys" "${lib.concatStringsSep "\n" cfgUser.openssh.authorizedKeys.keys}"} "''${HOME}/.ssh/authorized_keys"
    '';
  };
}
