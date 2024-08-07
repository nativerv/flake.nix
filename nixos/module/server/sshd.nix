{ ... }:
{
  lib,
  ...
}:
{
  # This setups an SSH server. Very important if you're setting up a headless system.
  # TODO: hardening
  services.openssh = {
    enable = true;

    settings = {
      # Forbid root login through SSH.
      # NOTE: required to be "yes" for `deploy-rs` deployments to this machine
      PermitRootLogin = lib.mkDefault "no";
      # Use keys only. Remove if you want to SSH using password (not recommended)
      PasswordAuthentication = false;
      Port = 42069;
      MaxAuthTries = 10;
    };
  };
}

