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
  cyrillic-nvim = pkgs.vimUtils.buildVimPlugin rec {
    pname = "cyrillic.nvim";
    version = "1";
    src = pkgs.fetchFromGitHub {
      name = "cyrillic.nvim";
      owner = "nativerv";
      repo = "cyrillic.nvim";
      rev = "86186af29eed2af1a069f9e36140d116a2765c80";
      sha256 = "sha256-B2NjvaKJbkih8HLgFAYVqmTuSKAj7XrCBPVoVpYCXXE=";
    };
  };
  plugins = with pkgs.vimPlugins; [
    # Core
    lazy-nvim

    # Text Nav
    camelcasemotion
    vim-visual-star-search

    # File Nav
    tmux-nvim
    telescope-nvim
    telescope-ui-select-nvim

    # Parsing & Highlighting
    nvim-treesitter.withAllGrammars
    nvim-treesitter-textobjects
    # vimPlugins.nvim-ts-context-commentstring

    # Editing
    nvim-autopairs
    vim-repeat
    nvim-surround
    vim-visual-multi

    # Features
    vim-fugitive
    gitsigns-nvim
    undotree
    image-nvim

    # QoL
    nvim-scrollview
    cyrillic-nvim
  ];
in mkMerge [
  {
    programs.neovim = {
      enable = true;
      defaultEditor = mkDefault true;

      inherit plugins;
    };

    # home.packages = with pkgs; [
    #   (writeShellScriptBin "${nvim-draft}" ''
    #     export NVIM_APPNAME="${nvim-draft}"
    #     exec ${config.programs.neovim.finalPackage}/bin/nvim "$@"
    #   '')
    # ];
  }

  # Install plugins
  # (mkMerge
  #   (map (plugin: { "${pluginsDir}/${plugin.name}".source = plugin.src; })
  #   plugins))

  # Install my config files
  (pipe (builtins.readDir ./neovim) [
    # Read dir & convert to HM .source's basically
    (mapAttrsToList (name: _: {
      xdg.configFile."nvim/${name}".source = ./neovim/${name};
    }))
    mkMerge
  ])
  # Install plugins for Lazy.nvim
  # {
  #   xdg.dataFile."nvim/lazy".source = pkgs.stdenv.mkDerivation {
  #     name = "nvim-lazy-plugins";
  #     src = ./.;
  #     installPhase = ''
  #       mkdir -p $out
  #       ${pipe plugins [
  #         (map (plugin:
  #           ''ln -s "${plugin}" "$out/${plugin.src.repo}"''
  #         ))
  #         (concatStringsSep "\n")
  #       ]}
  #     '';
  #   };
  #   xdg.dataFile."tree-sitter".source =
  #     "${head pkgs.vimPlugins.nvim-treesitter.withAllGrammars.passthru.dependencies}";
  # }
  # Equivalent to the above:
  {
    xdg.dataFile."nvim/lazy".source =
      "${pkgs.vimUtils.packDir config.programs.neovim.finalPackage.passthru.packpathDirs}/pack/myNeovimPackages/start";
    xdg.dataFile."tree-sitter".source =
      "${head pkgs.vimPlugins.nvim-treesitter.withAllGrammars.passthru.dependencies}";
  }

  # Draft
  # (pipe (builtins.readDir ./neovim-draft) [
  #   # Read dir & convert to HM .source's basically
  #   (mapAttrsToList (name: _: {
  #     xdg.configFile."${nvim-draft}/${name}".source = ./neovim-draft/${name};
  #   }))
  #   mkMerge
  # ])
  # (pipe plugins [
  #   # Install (symlink) plugins to the custom dir - to source later with plugin
  #   # manager
  #   (map (plugin: {
  #     xdg.dataFile."${nvim-draft}/lazy/${plugin.src.repo}".source = plugin;
  #   }))
  #   mkMerge
  # ])
  # {
  #   xdg.dataFile."${nvim-draft}/lazy".source = pkgs.stdenv.mkDerivation {
  #     name = "nvim-plugins";
  #     src = ./.;
  #     installPhase = ''
  #       mkdir -p $out
  #       ${pipe plugins [
  #         (map (plugin:
  #           ''ln -s "${plugin}" "$out/${plugin.src.repo}"''
  #         ))
  #         (concatStringsSep "\n")
  #       ]}
  #     '';
  #   };
  # }
]
