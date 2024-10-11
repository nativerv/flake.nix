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
  cfg = config.dream.subsystem.networking;
in
{
  options.dream.subsystem.networking.dns = {
    # TODO: hand-select servers so my url queries in browser don't hang
    dnscrypt = mkEnableOption "Enable dnscrypt";
  };
  config = {
    services.dnscrypt-proxy2.enable = cfg.dns.dnscrypt;
  };
}
