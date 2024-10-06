{
  self,
  flake,
  ...
}:
{
  lib,
  config,
  pkgs,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.program.tmux;
in
{
  options.dream.program.tmux = {
    enable = mkEnableOption "Enable program.tmux";
  };
  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;

      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.resurrect.overrideAttrs (old: {
            version = "6be2f34";
            src = fetchFromGitHub {
              inherit (old.src) owner repo;
              rev = "6be2f34b5f06c8a6a23dc3dc835e69c132d58a18";
              sha256 = "sha256-1NXk75eZbhLEq0KKpLaFegPj0xLvWnLrVVfPxK1mk18=";
            };
          });
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
      ];

      # Import my old config for now - seems to work fine apart from plugins
      extraConfig = builtins.readFile ./tmux/tmux.conf;
    };
  };
}
