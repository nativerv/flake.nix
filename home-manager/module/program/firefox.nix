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
with self.lib;
with lib;
let
in mkMerge [
  {
    programs.firefox = {
      enable = true;
      package = self.packages.${pkgs.system}.firefox.override {
        nativeMessagingHosts = [
          # Injects audio into WebRTC screensharing natively
          inputs.pipewire-screenaudio.packages.${pkgs.system}.default
        ];
      };
    };
  }
]
