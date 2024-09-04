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
  nvim-draft = "nvim-draft";
  plugins = with pkgs; [
    vimPlugins.lazy-nvim
    vimPlugins.tmux-nvim
  ];
in mkMerge [
  {
    programs.neovim = {
      enable = true;
      defaultEditor = mkDefault true;

      inherit plugins;
    };

    home.packages = with pkgs; [
      (writeShellScriptBin "${nvim-draft}" ''
        export NVIM_APPNAME="${nvim-draft}"
        exec ${config.programs.neovim.finalPackage}/bin/nvim "$@"
      '')
    ];
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

  # Draft
  (pipe (builtins.readDir ./neovim-draft) [
    # Read dir & convert to HM .source's basically
    (mapAttrsToList (name: _: {
      xdg.configFile."${nvim-draft}/${name}".source = ./neovim-draft/${name};
    }))
    mkMerge
  ])
  # (pipe plugins [
  #   # Install (symlink) plugins to the custom dir - to source later with plugin
  #   # manager
  #   (map (plugin: {
  #     xdg.dataFile."${nvim-draft}/lazy/${plugin.src.repo}".source = plugin;
  #   }))
  #   mkMerge
  # ])
  {
    xdg.dataFile."${nvim-draft}/lazy".source = pkgs.stdenv.mkDerivation {
      name = "nvim-plugins";
      src = ./.;
      installPhase = ''
        mkdir -p $out
        ${pipe plugins [
          (map (plugin:
            ''ln -s "${plugin}" "$out/${plugin.src.repo}"''
          ))
          (concatStringsSep "\n")
        ]}
      '';
    };
  }
]
