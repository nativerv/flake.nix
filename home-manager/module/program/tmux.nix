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
{
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
    extraConfig = builtins.readFile "${flake}/home-manager/module/program/tmux/tmux.conf";
  };
}
