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
  utils,
  ...
}:
with lib;
with self.lib;
with builtins;
let
  cfg = config.home-manager.standalone;
  userOpts = {
    options = {
      enable =
        mkEnableOption "Enable home-manager standalone activation for this user";

      defaultConfiguration = mkOption {
        type = types.package;
        example = literalExpression "self.homeConfigurations.alice.activationPackage";
        description = ''Activation package to use if home-manager profile is not present'';
      };

      verbose = mkEnableOption "verbose output on activation";

      backupFileExtension = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "backup";
        description = ''
          On activation move existing files by appending the given
          file extension rather than exiting with an error.
        '';
      };
    };
  };
  generateUnit = name: userCfg: nameValuePair
    "home-manager-standalone-${utils.escapeSystemdPath name}"
    {
      description = "Home Manager environment for ${name} (standalone)";
      wantedBy = [ "multi-user.target" ];
      wants = [ "nix-daemon.socket" ];
      after = [ "nix-daemon.socket" ];
      before = [ "systemd-user-sessions.service" ];

      environment = optionalAttrs (userCfg.backupFileExtension != null) {
        HOME_MANAGER_BACKUP_EXT = userCfg.backupFileExtension;
      } // optionalAttrs userCfg.verbose { VERBOSE = "1"; }; 

      unitConfig = { RequiresMountsFor = "/home/${name}"; };

      stopIfChanged = false;

      serviceConfig = {
        User = name;
        Type = "oneshot";
        RemainAfterExit = "yes";
        TimeoutStartSec = "5m";
        SyslogIdentifier = "hm-standalone-activate-${name}";

        ExecStart = let
          systemctl =
            "XDG_RUNTIME_DIR=\${XDG_RUNTIME_DIR:-/run/user/$UID} systemctl";

          sed = "${pkgs.gnused}/bin/sed";

          exportedSystemdVariables = concatStringsSep "|" [
            "DBUS_SESSION_BUS_ADDRESS"
            "DISPLAY"
            "WAYLAND_DISPLAY"
            "XAUTHORITY"
            "XDG_RUNTIME_DIR"
          ];
          setupEnv = pkgs.writeScript "hm-setup-env" ''
            #! ${pkgs.runtimeShell} -el

            # The activation script is run by a login shell to make sure
            # that the user is given a sane environment.
            # If the user is logged in, import variables from their current
            # session environment.
            eval "$(
              ${systemctl} --user show-environment 2> /dev/null \
              | ${sed} -En '/^(${exportedSystemdVariables})=/s/^/export /p'
            )"

            exec "$1/activate"
          '';
        in builtins.toString (pkgs.writeScript "hm-standalone-activate" /* bash */ ''
          #! ${pkgs.runtimeShell} -el
          
          # FIXME(hardcoded): XDG dir, might be using legacy
          standalone_activation_package="''${XDG_STATE_HOME:-"$HOME/.local/state"}/nix/profiles/home-manager"
          activation_package="${userCfg.defaultConfiguration}"
          [ -f "''${standalone_activation_package}/activate" ] &&
            activation_package="''${standalone_activation_package}"
          ${setupEnv} "''${activation_package}"
        '');
      };
    };
in {
  options = {
    home-manager.standalone = {
      users = mkOption {
        description = "Users for whom to activate standalone home-manager installations during system activatin.";
        default = {};
        example = {
          alice = {
            enable = true;
            defaultConfiguration = literalExpression "self.homeConfigurations.alice.activationPackage";
            backupFileExtension = "hm-bak";
          };
        };
        type = with types; attrsOf (submodule userOpts);
      };
    };
  };
  config = mkIf (cfg.users != {}) {
    systemd.services = mapAttrs' generateUnit cfg.users;
  };
}
