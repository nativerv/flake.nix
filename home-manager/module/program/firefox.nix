{
  self,
  flake,
  inputs,
  ...
}:
{
  pkgs,
  lib,
  config,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.program.firefox;
  firefox-dream = self.packages.${pkgs.system}.firefox.override {
    nativeMessagingHosts = [
      # Injects audio into WebRTC screensharing natively
      inputs.pipewire-screenaudio.packages.${pkgs.system}.default
    ];
  };
in
{
  options.dream.program.firefox = {
    enable = mkEnableOption "Enable program.firefox";
  };
  config = mkIf cfg.enable (mkMerge [
    {
      programs.firefox = {
        enable = true;
        package = firefox-dream;
      };
    }
  ]);
}
