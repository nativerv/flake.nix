{ ... }:
{ ... }: {
  # This setups an SSH server. Very important if you're setting up a headless system.
  services.openssh = {
    enable = true;

    settings = {
      # Forbid root login through SSH.
      #PermitRootLogin = "no";
      # Use keys only. Remove if you want to SSH using password (not recommended)
      # TODO: look at /etc/ssh/sshd_config and do cool stuff here
      PasswordAuthentication = false;
    };
  };
}
