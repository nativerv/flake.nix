{
  self ? null,
  ...
}:
{
  config ? null,
  lib ? null,
  pkgs ? null,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.program.sudo;
in
{
  options.dream.program.sudo = {
    enable = mkEnableOption "Enable program.sudo";
  };
  config = mkIf cfg.enable {
    security.sudo.extraConfig = ''
      Defaults timestamp_timeout=10080,insults
    '';
    security.sudo.extraRules = [
      # # Allow execution of any command by all users in group sudo,
      # # requiring a password.
      # { groups = [ "sudo" ]; commands = [ "ALL" ]; }
      #
      # # Allow execution of "/home/root/secret.sh" by user `backup`, `database`
      # # and the group with GID `1006` without a password.
      # {
      #   users = [ "backup" "database" ];
      #   groups = [ 1006 ];
      #   commands = [
      #     { command = "/home/root/secret.sh"; options = [ "SETENV" "NOPASSWD" ]; }
      #   ];
      # }
      #
      # # Allow all users of group `bar` to run two executables as user `foo`
      # # with arguments being pre-set.
      # {
      #   groups = [ "bar" ];
      #   runAs = "foo";
      #   commands = [
      #     "/home/baz/cmd1.sh hello-sudo"
      #     { command = ''/home/baz/cmd2.sh ""''; options = [ "SETENV" ]; }
      #   ];
      # }
      # # Allow user `foo` to run systemctl restart on `bar.service` without password
      # security.sudo.extraRules = [
      #   {
      #     users = [ "foo" ];
      #     commands = [
      #       {
      #         command = "${pkgs.systemd}/bin/systemctl restart bar.service";
      #         options = [ "NOPASSWD" ];
      #       }
      #     ];
      #   }
      # ];
    ];
  };
}
