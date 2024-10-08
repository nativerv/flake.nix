{
  self ? null,
  ...
}:
{
  config ? null,
  lib ? null,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.server.sshd;
in
# TODO: more ssh implementations?
{
  options.dream.server.sshd = {
    enable = mkEnableOption "Enable server.sshd - SSH server";
    port = mkOption {
      type = types.port;
      default = 42069;
    };
    permitRootLogin = mkOption {
      type = types.bool;
      default = false;
    };
  };
  config = mkIf cfg.enable {
    # This setups an SSH server. Very important if you're setting up a headless system.
    # TODO: hardening
    services.openssh = {
      enable = true;

      settings = {
        # Forbid root login through SSH.
        # NOTE: required to be "yes" for `deploy-rs` deployments to this machine
        PermitRootLogin = if cfg.permitRootLogin then "yes" else "no";
        # Use keys only. Remove if you want to SSH using password (not recommended)
        PasswordAuthentication = false;
        Port = cfg.port;
        MaxAuthTries = 10;
      };
    };
  };
}

