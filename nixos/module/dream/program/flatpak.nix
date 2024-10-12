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
  cfg = config.dream.program.flatpak;
in
{
  options.dream.program.flatpak = {
    enable = mkEnableOption "Enable program.flatpak - stateful, distro-independed package manager";
  };
  config = mkIf cfg.enable {
    services.flatpak.enable = true;
    systemd.services.install-flatpak-repos = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = [ pkgs.flatpak ];
      serviceConfig.Type = "oneshot";
      script = ''
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
