# Hotkeys
{
  self,
  inputs,
  ...
}:
{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with self.lib;
with builtins;
{
  # users.groups.keyd = {};
  services.keyd.enable = true;
  systemd.services.keyd = {
    path = [
      inputs.session.packages.${pkgs.system}.default
      inputs.envrund.packages.${pkgs.system}.default
    ];
    restartTriggers = [
      config.environment.etc."keyd/keyd.conf".source
    ];
    serviceConfig = mkForce (flip removeAttrs [
      # Causes: mkdir: cannot create directory ‘/run/user’: Permission denied
      #               session: ERROR: cannot create folder for the session name
      #               'tty7': file exists
      "ProtectHome"

      # Causes: silently nothing happend (i think because ttyuserdo needs
      #               /sys?)
      "ProtectProc"
      "ProtectSystem"

      # Causes: .ttyuserdo-wrapped: line 11: 368410 Bad system call         sudo -u "${user}" sh -c "exec ${1}"
      "SystemCallFilter"

      # Causes (in the /tmp/keyd-test):
      #   sudo: PERM_SUDOERS: setresuid(-1, 1, -1): Operation not permitted
      #   sudo: unable to open /etc/sudoers: Operation not permitted
      #   sudo: error initializing audit plugin sudoers_audit
      # And (in the jc -efu keyd):
      #   Aug 30 23:01:30 adamantia sudo[458487]:     root : unable to open /etc/sudoers : Operation not permitted ; PWD=/ ; USER=nrv ;
      "CapabilityBoundingSet"

      # Causes: Error: /proc must be mounted
      "ProcSubset"

      # Needed for /tmp/keyd-test
      "PrivateTmp"

      # These are fine
      # "PrivateMounts"
      # "PrivateNetwork"
      # "PrivateUsers"
      # "IPAddressDeny"
      # "LockPersonality"
      # "MemoryDenyWriteExecute"
      # "NoNewPrivileges"
      # "ProtectClock"
      # "ProtectControlGroups"
      # "ProtectKernelTunables"
      # "Restart"
      # "RestrictAddressFamilies"
      # "RestrictNamespaces"
      # "SupplementaryGroups"
      # "ProtectHostname"
      # "ProtectKernelLogs"
      # "ProtectKernelModules"
      # "RestrictRealtime"
      # "RestrictSUIDSGID"
      # "RuntimeDirectory"
    ] {
      ExecStart = mkForce "${pkgs.keyd}/bin/keyd";
      DeviceAllow = mkForce [ "/dev/uinput rw" "char-input rw" ];

      CapabilityBoundingSet = mkForce "CAP_SYS_NICE";
      IPAddressDeny = mkForce "any";
      LockPersonality = mkForce true;
      MemoryDenyWriteExecute = mkForce true;
      NoNewPrivileges = mkForce true;
      PrivateMounts = mkForce true;
      PrivateNetwork = mkForce true;
      PrivateTmp = mkForce true;
      PrivateUsers = mkForce false;
      ProcSubset = mkForce "pid";
      ProtectClock = mkForce true;
      ProtectControlGroups = mkForce true;
      ProtectHome = mkForce true;
      ProtectHostname = mkForce true;
      ProtectKernelLogs = mkForce true;
      ProtectKernelModules = mkForce true;
      ProtectKernelTunables = mkForce true;
      ProtectProc = mkForce "invisible";
      ProtectSystem = mkForce "strict";
      Restart = mkForce "always";
      RestrictAddressFamilies = mkForce "AF_UNIX";
      RestrictNamespaces = mkForce true;
      RestrictRealtime = mkForce true;
      RestrictSUIDSGID = mkForce true;
      RuntimeDirectory = mkForce "keyd";
      SupplementaryGroups = mkForce [ "input" "uinput" ];
      SystemCallFilter = mkForce [ "nice" "@system-service" "~@privileged" ];

      UMask = mkForce "0077";
    });
  };

  environment.etc."keyd/keyd.conf".source = lib.mkForce ./keyd/keyd.conf;
}
