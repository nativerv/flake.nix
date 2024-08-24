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
    programs.neovim = {
      enable = true;
      defaultEditor = mkDefault true;
    };
  }

  # Install plugins
  # (mkMerge
  #   (map (plugin: { "${pluginsDir}/${plugin.name}".source = plugin.src; })
  #   plugins))

  # Install my config files
  # Which is uglier?
  # (mkMerge (mapAttrsToList (name: _: { "${configDir}/${name}".source = ./zsh/${name}; }) (builtins.readDir ./zsh)))
  (pipe (builtins.readDir ./neovim) [
    # Read dir & convert to HM .source's basically
    (mapAttrsToList (name: _: {
      xdg.configFile."nvim/${name}".source = ./neovim/${name};
    }))
    mkMerge
  ])
  # builtins.readDir ./neovim
  #   # Read dir & convert to HM .source's basically
  #   |> mapAttrsToList (name: _: {
  #     xdg.configFile."nvim/${name}".source = ./neovim/${name};
  #   })
  #   |> mkMerge
]
