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
  cfg = config.dream.program.neovim;

  nvim-draft = "nvim-draft";

  inherit (pkgs) fetchFromGitHub;

  inherit (pkgs.vimUtils) buildVimPlugin;
  inherit (pkgs.neovimUtils) buildNeovimPlugin;

  # FIXME: these all are probably still using deps from nixpkgs and ignoring my overrides. not that serious though it's only plenary and nvim-treesitter i think.
  # FIXME: do even src overrides work?
  dreamPlugins = { 
    cyrillic-nvim = buildVimPlugin {
      pname = "cyrillic.nvim";
      version = "1";
      src = fetchFromGitHub {
        name = "cyrillic.nvim";
        owner = "nativerv";
        repo = "cyrillic.nvim";
        rev = "86186af29eed2af1a069f9e36140d116a2765c80";
        sha256 = "sha256-B2NjvaKJbkih8HLgFAYVqmTuSKAj7XrCBPVoVpYCXXE=";
      };
    };

    plenary-nvim = buildNeovimPlugin {
      pname = "plenary.nvim";
      version = "2024-09-17";
      src = fetchFromGitHub {
        owner = "nvim-lua";
        repo = "plenary.nvim";
        rev = "2d9b06177a975543726ce5c73fca176cedbffe9d";
        sha256 = "1blmh0qr010jhydw61kiynll2m7q4xyrvrva8b5ipf1g81x8ysbf";
      };
      meta.homepage = "https://github.com/nvim-lua/plenary.nvim/";
    };

    lazy-nvim = pkgs.vimPlugins.lazy-nvim.overrideAttrs {
      pname = "lazy.nvim";
      version = "2024-12-13";
      src = fetchFromGitHub {
        owner = "folke";
        repo = "lazy.nvim";
        rev = "7e6c863bc7563efbdd757a310d17ebc95166cef3";
        sha256 = "1xp6da2jg09428280015kpqblm5qms6bhldlwvfwhw9hlxkvmj73";
      };
      meta.homepage = "https://github.com/folke/lazy.nvim/";
    };

    camelcasemotion = buildVimPlugin {
      pname = "camelcasemotion";
      version = "2019-12-02";
      src = fetchFromGitHub {
        owner = "bkad";
        repo = "camelcasemotion";
        rev = "de439d7c06cffd0839a29045a103fe4b44b15cdc";
        sha256 = "0yfsb0d9ly8abmc95nqcmr8r8ylif80zdjppib7g1qj1wapdhc69";
      };
      meta.homepage = "https://github.com/bkad/camelcasemotion/";
    };

    tmux-nvim = buildVimPlugin {
      pname = "tmux.nvim";
      version = "2024-10-25";
      src = fetchFromGitHub {
        owner = "aserowy";
        repo = "tmux.nvim";
        rev = "307bad95a1274f7288aaee09694c25c8cbcd6f1a";
        sha256 = "1kwng294hm9may49byvxhmpzylpzw9hfp8ngafd8i93swb16rzbk";
      };
      meta.homepage = "https://github.com/aserowy/tmux.nvim/";
    };

    telescope-nvim = pkgs.vimPlugins.telescope-nvim.overrideAttrs {
      pname = "telescope.nvim";
      version = "2024-11-29";
      src = fetchFromGitHub {
        owner = "nvim-telescope";
        repo = "telescope.nvim";
        rev = "2eca9ba22002184ac05eddbe47a7fe2d5a384dfc";
        sha256 = "0bkpys6dj01x6ycylmf6vrd2mqjibmny9a2hxxrqn0jqqvagm5ly";
      };
      meta.homepage = "https://github.com/nvim-telescope/telescope.nvim/";

      dependencies = [ dreamPlugins.plenary-nvim ];
    };

    telescope-ui-select-nvim = buildVimPlugin {
      pname = "telescope-ui-select.nvim";
      version = "2023-12-04";
      src = fetchFromGitHub {
        owner = "nvim-telescope";
        repo = "telescope-ui-select.nvim";
        rev = "6e51d7da30bd139a6950adf2a47fda6df9fa06d2";
        sha256 = "1cgi4kmq99ssx97nnriff5674cjfvc3qsw62nx3iz0xqc6d4s631";
      };
      meta.homepage = "https://github.com/nvim-telescope/telescope-ui-select.nvim/";

      dependencies = [ dreamPlugins.telescope-nvim ];
    };

    nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.overrideAttrs {
      pname = "nvim-treesitter";
      version = "2024-12-28";
      src = fetchFromGitHub {
        owner = "nvim-treesitter";
        repo = "nvim-treesitter";
        rev = "5d18ef22dc63624e90aa7b6dbc17f2c3856ae716";
        sha256 = "1cf672phpy24743xg553na6pkfvyl0ngi1ww862x4gzgzyzlgqh7";
      };
      meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter/";
    };

    nvim-treesitter-textobjects = buildVimPlugin {
      pname = "nvim-treesitter-textobjects";
      version = "2024-11-22";
      src = fetchFromGitHub {
        owner = "nvim-treesitter";
        repo = "nvim-treesitter-textobjects";
        rev = "ad8f0a472148c3e0ae9851e26a722ee4e29b1595";
        sha256 = "08vlvi9iwhl5qy924s6dmxaczg1yg096vdchp7za5p7wnb7w3zkg";
      };
      meta.homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects/";

      dependencies = [ dreamPlugins.nvim-treesitter ];
    };

    vim-visual-star-search = buildVimPlugin {
      pname = "vim-visual-star-search";
      version = "2021-07-14";
      src = fetchFromGitHub {
        owner = "bronson";
        repo = "vim-visual-star-search";
        rev = "7c32edb9e3c85d473d9be4dec721a4c9d5d4d69c";
        sha256 = "1g3n84bwvy2535n8xwh14j3s8n1jwvl577vigg8zsxxvhjzl878b";
      };
      meta.homepage = "https://github.com/bronson/vim-visual-star-search/";
    };

    nvim-autopairs = pkgs.vimPlugins.nvim-autopairs.overrideAttrs {
      pname = "nvim-autopairs";
      version = "2024-11-17";
      src = fetchFromGitHub {
        owner = "windwp";
        repo = "nvim-autopairs";
        rev = "b464658e9b880f463b9f7e6ccddd93fb0013f559";
        sha256 = "0p4v49saqfsc8kinl3wc3zhmr6m2q86vmay2f10payp29n4v3did";
      };
      meta.homepage = "https://github.com/windwp/nvim-autopairs/";
    };

    vim-repeat = buildVimPlugin {
      pname = "vim-repeat";
      version = "2024-07-08";
      src = fetchFromGitHub {
        owner = "tpope";
        repo = "vim-repeat";
        rev = "65846025c15494983dafe5e3b46c8f88ab2e9635";
        sha256 = "0n8sx6s2sbjb21dv9j6y5lyqda9vvxraffg2jz423daamn96dxqv";
      };
      meta.homepage = "https://github.com/tpope/vim-repeat/";
    };

    nvim-surround = pkgs.vimPlugins.nvim-surround.overrideAttrs {
      pname = "nvim-surround";
      version = "2024-11-28";
      src = fetchFromGitHub {
        owner = "kylechui";
        repo = "nvim-surround";
        rev = "9f0cb495f25bff32c936062d85046fbda0c43517";
        sha256 = "1c78320liqhza52gq2xylykd9m6rl50cn44flldg43a4l7rrabxh";
      };
      meta.homepage = "https://github.com/kylechui/nvim-surround/";
    };

    vim-visual-multi = buildVimPlugin {
      pname = "vim-visual-multi";
      version = "2024-09-01";
      src = fetchFromGitHub {
        owner = "mg979";
        repo = "vim-visual-multi";
        rev = "a6975e7c1ee157615bbc80fc25e4392f71c344d4";
        sha256 = "15jrxvaip6mncl8b8q8c1i82m20m1mld11gv75x9hqng3y85cc1b";
      };
      meta.homepage = "https://github.com/mg979/vim-visual-multi/";
    };

    vim-fugitive = buildVimPlugin {
      pname = "vim-fugitive";
      version = "2024-12-15";
      src = fetchFromGitHub {
        owner = "tpope";
        repo = "vim-fugitive";
        rev = "fcb4db52e7f65b95705aa58f0f2df1312c1f2df2";
        sha256 = "1iyb3qxyf0x26q7ndx1ycq1ankqwr0bw6qghv8kw1mnr5c9b15rw";
      };
      meta.homepage = "https://github.com/tpope/vim-fugitive/";
    };

    gitsigns-nvim = pkgs.vimPlugins.gitsigns-nvim.overrideAttrs {
      pname = "gitsigns.nvim";
      version = "2024-11-23";
      src = fetchFromGitHub {
        owner = "lewis6991";
        repo = "gitsigns.nvim";
        rev = "5f808b5e4fef30bd8aca1b803b4e555da07fc412";
        sha256 = "1dxsyv26mm7lzll3xlkzjj6w7kp11wfak8rgp19fg2d8301kxc0z";
      };
      meta.homepage = "https://github.com/lewis6991/gitsigns.nvim/";

      dependencies = [ dreamPlugins.plenary-nvim ];
      doInstallCheck = true;
      nvimRequireCheck = "eblan";
    };

    undotree = buildVimPlugin {
      pname = "undotree";
      version = "2024-09-19";
      src = fetchFromGitHub {
        owner = "mbbill";
        repo = "undotree";
        rev = "78b5241191852ffa9bb5da5ff2ee033160798c3b";
        sha256 = "1w4sdbcvlicb3n4dpzv8l9g41xl3pqslni227lf88b4p5pjsfkax";
      };
      meta.homepage = "https://github.com/mbbill/undotree/";
    };

    image-nvim = pkgs.vimPlugins.image-nvim.overrideAttrs {
      pname = "image.nvim";
      version = "2024-12-26";
      src = fetchFromGitHub {
        owner = "3rd";
        repo = "image.nvim";
        rev = "b991fc7f845bc6ab40c6ec00b39750dcd5190010";
        sha256 = "1jbbm4l71w0cas0aj5d0jsy65chbvf4bdxxllb04i3k6h1zycdja";
      };
      meta.homepage = "https://github.com/3rd/image.nvim/";

      dependencies = [ dreamPlugins.nvim-treesitter-override ];
    };

    nvim-treesitter-override = dreamPlugins.nvim-treesitter.withPlugins (p: (let
      allGrammarsNames = [ "ada" "agda" "angular" "apex" "arduino" "asm" "astro" "authzed" "bash" "bass" "beancount" "bibtex" "bicep" "bitbake" "blueprint" "bp" "c" "c_sharp" "cairo" "capnp" "chatito" "circom" "clojure" "cmake" "comment" "commonlisp" "cooklang" "corn" "cpon" "cpp" "css" "csv" "cuda" "cue" "cylc" "d" "dart" "desktop" "devicetree" "dhall" "diff" "disassembly" "djot" "dockerfile" "dot" "doxygen" "dtd" "earthfile" "ebnf" "editorconfig" "eds" "eex" "elixir" "elm" "elsa" "elvish" "erlang" "facility" "faust" "fennel" "fidl" "firrtl" "fish" "foam" "forth" "fortran" "fsh" "fsharp" "func" "fusion" "gdscript" "gdshader" "git_config" "git_rebase" "gitattributes" "gitcommit" "gitignore" "gleam" "glimmer" "glimmer_javascript" "glimmer_typescript" "glsl" "gn" "gnuplot" "go" "goctl" "godot_resource" "gomod" "gosum" "gotmpl" "gowork" "gpg" "graphql" "gren" "groovy" "gstlaunch" "hare" "haskell" "haskell_persistent" "hcl" "heex" "helm" "hjson" "hlsl" "hlsplaylist" "hocon" "hoon" "html" "htmldjango" "http" "hurl" "hyprlang" "idl" "ini" "inko" "ispc" "janet_simple" "java" "javascript" "jq" "jsdoc" "json" "json5" "jsonc" "jsonnet" "julia" "just" "kconfig" "kdl" "kotlin" "koto" "kusto" "lalrpop" "latex" "ledger" "leo" "linkerscript" "liquid" "liquidsoap" "llvm" "lua" "luadoc" "luap" "luau" "m68k" "make" "markdown" "markdown_inline" "matlab" "menhir" "meson" "mlir" "muttrc" "nasm" "nginx" "nim" "nim_format_string" "ninja" "nix" /*"norg"*/ "nqc" "nu" "objc" "objdump" "ocaml" "ocaml_interface" "ocamllex" "odin" "pascal" "passwd" "pem" "perl" "php" "php_only" "phpdoc" "pioasm" "po" "pod" "poe_filter" "pony" "powershell" "printf" "prisma" "problog" "prolog" "promql" "properties" "proto" "prql" "psv" "pug" "puppet" "purescript" "pymanifest" "python" "ql" "qmldir" "qmljs" "query" "r" "ralph" "rasi" "rbs" "re2c" "readline" "regex" "rego" "requirements" "rescript" "rnoweb" "robot" "robots" "roc" "ron" "rst" "ruby" "runescript" "rust" "scala" "scfg" "scss" "sflog" "slang" "slint" "smali" "smithy" "solidity" "soql" "sosl" "sourcepawn" "sparql" "sql" "squirrel" "ssh_config" "starlark" "strace" "styled" "supercollider" "superhtml" "surface" "svelte" "sway" "swift" "sxhkdrc" "systemtap" "t32" "tablegen" "tact" "tcl" "teal" "templ" "terraform" "textproto" "thrift" "tiger" "tlaplus" "tmux" "todotxt" "toml" "tsv" "tsx" "turtle" "twig" "typescript" "typespec" "typoscript" "typst" "udev" "ungrammar" "unison" "usd" "uxntal" "v" "vala" "vento" "verilog" "vhdl" "vhs" "vim" "vimdoc" "vrl" "vue" "wgsl" "wgsl_bevy" "wing" "wit" "xcompose" "xml" "xresources" "yaml" "yang" "yuck" "zathurarc" "zig" "ziggy" "ziggy_schema" ];
      overrides = {
        odin = p.odin.overrideAttrs (let 
          rev = "d2ca8efb4487e156a60d5bd6db2598b872629403";
        in {
          version = "0.0.0+rev=${substring 0 7 rev}";
          src = fetchFromGitHub {
            owner = "tree-sitter-grammars";
            repo = "tree-sitter-odin";
            inherit rev;
            hash = "sha256-aPeaGERAP1Fav2QAjZy1zXciCuUTQYrsqXaSQsYG0oU=";
          };
        });
      };
      allExceptOverridden = pipe allGrammarsNames [
        (map (s: { name = s; value = p.${s}; }))
        (listToAttrs)
        (filterAttrs (name: _: !elem name (attrNames overrides)))
        (attrValues)
      ];
    in allExceptOverridden ++ (attrValues overrides)
    ));
  };
  plugins = [
    # Core
    dreamPlugins.lazy-nvim

    # Theme
    # rose-pine

    # Text Nav
    dreamPlugins.camelcasemotion
    dreamPlugins.vim-visual-star-search

    # File Nav
    dreamPlugins.tmux-nvim
    dreamPlugins.telescope-nvim
    dreamPlugins.telescope-ui-select-nvim

    # Parsing & Highlighting
    dreamPlugins.nvim-treesitter-override
    dreamPlugins.nvim-treesitter-textobjects
    # # NOTE: this may be useful:
    # # (https://old.reddit.com/r/NixOS/comments/157fpi1/how_to_pass_environment_variables_to_treesitter/)
    # (nvim-treesitter.withPlugins (p: [
    #   (p.markdown.overrideAttrs { 
    #     env.EXTENSION_WIKI_LINK = "1"; 
    #     nativeBuildInputs = [ pkgs.nodejs pkgs.tree-sitter ];
    #     configurePhase = ''
    #     cd tree-sitter-markdown
    #     tree-sitter generate
    #     '';
    #   })
    # ]))
    # vimPlugins.nvim-ts-context-commentstring

    # Editing
    dreamPlugins.nvim-autopairs
    dreamPlugins.vim-repeat
    dreamPlugins.nvim-surround
    dreamPlugins.vim-visual-multi

    # Features
    dreamPlugins.vim-fugitive
    dreamPlugins.gitsigns-nvim
    dreamPlugins.undotree
    dreamPlugins.image-nvim

    # QoL
    #dreamPlugins.nvim-scrollview
    dreamPlugins.cyrillic-nvim
  ];
in {
  options.dream.program.neovim = {
    enable = mkEnableOption "Enable program.neovim";
  };
  config = mkIf cfg.enable (mkMerge [
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
      xdg.dataFile."tree-sitter".source = pkgs.symlinkJoin {
        name = "treesitter-all-parsers";
        paths = dreamPlugins.nvim-treesitter-override.passthru.dependencies;
      };
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
  ]);
}
