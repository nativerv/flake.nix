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
  cfg = config.dream.archetype.impermanent;
in
{
  options.dream.archetype.impermanent = with types; {
    enable = mkEnableOption "Enable archetype.impermanent";
    rootfs = mkOption {
      type = lib.types.enum [ "tmpfs" "manual" ];
      default = "tmpfs";
      description = "Kind of ephemeral filesystem to use for / mountpoint.";
    };
    persist = mkOption {
      description = "Persistency roots. Must be mountpoints, can be a single one for all, multiple ones or different for each one. The idea is both backup priority & filesystem option separation. See suboptions for details.";
      type = submodule {
        options.data = mkOption {
          type = path;
          description = "Folder for persisted 'data' - user data of top importance that cannot be tri{ially recreated.";
        };
        options.log = mkOption {
          type = path;
          description = "Folder for persisted logs - automatic log data of little but existing importance.";
        };
        options.state = mkOption {
          type = path;
          description = "Folder for persisted 'state' - interacti}e application configuration state, data which can be recreated manually.";
        };
        options.cache = mkOption {
          type = path;
          description = "Folder for persisted cache - completely application-regeneratable data wanted to be persisted only for performance reasons.";
        };
        options.cred = mkOption {
          type = path;
          description = "Folder for persisted credentials - keyfiles, etc: upmost importance, tiny size, separated for easy backups.";
        };
      };
    };
  };
  config = mkIf cfg.enable {
    assertions = flip map (attrsToList cfg.persist) ({ name, value }: {
      assertion = config.fileSystems."${value}" or null != null;
      message = "Persistence root '${name}' (dream.archetype.impermanent.persist.${name}) must be a mountpoint";
    }) ++ [
      { assertion = cfg.rootfs == "manual"; message = "Not implemented"; }
    ];
  };
}
