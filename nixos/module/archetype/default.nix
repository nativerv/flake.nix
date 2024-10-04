# This is not a 'default' module but an archetype named 'default'
# It contains stuff that all my default systems should have.
# For an unopinionated (not really) defaults to to sane.nix.
{
  self ? null,
  ...
}:
{
  config,
  lib,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.archetype.default;
in
{
  imports = [
    self.nixosModules."archetype.sane"
  ];
  options.dream.archetype.default = {
    enable = mkEnableOption "Enable archetype.default";
  };
  config = mkIf cfg.enable {
    dream.archetype.sane.enable = true;
    # My custom groups under my own gid range. Defined in a common config file.
    # NOTE: NixOS does not permit specifying extra groups as gids.
    #       All of the places referencing my custom groups would refer to the
    #       shared config instead of hard string names if it were not the case.
    # TODO: maybe fix the NixOS gid thing in the future.
    users.groups = self.config.groups;
  };
}

