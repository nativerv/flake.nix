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

  nvim-treesitter-override = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: (let
    allGrammarsNames = [ "ada" "agda" "angular" "apex" "arduino" "asm" "astro" "authzed" "bash" "bass" "beancount" "bibtex" "bicep" "bitbake" "blueprint" "bp" "c" "c_sharp" "cairo" "capnp" "chatito" "circom" "clojure" "cmake" "comment" "commonlisp" "cooklang" "corn" "cpon" "cpp" "css" "csv" "cuda" "cue" "cylc" "d" "dart" "desktop" "devicetree" "dhall" "diff" "disassembly" "djot" "dockerfile" "dot" "doxygen" "dtd" "earthfile" "ebnf" "editorconfig" "eds" "eex" "elixir" "elm" "elsa" "elvish" "erlang" "facility" "faust" "fennel" "fidl" "firrtl" "fish" "foam" "forth" "fortran" "fsh" "fsharp" "func" "fusion" "gdscript" "gdshader" "git_config" "git_rebase" "gitattributes" "gitcommit" "gitignore" "gleam" "glimmer" "glimmer_javascript" "glimmer_typescript" "glsl" "gn" "gnuplot" "go" "goctl" "godot_resource" "gomod" "gosum" "gotmpl" "gowork" "gpg" "graphql" "gren" "groovy" "gstlaunch" "hare" "haskell" "haskell_persistent" "hcl" "heex" "helm" "hjson" "hlsl" "hlsplaylist" "hocon" "hoon" "html" "htmldjango" "http" "hurl" "hyprlang" "idl" "ini" "inko" "ispc" "janet_simple" "java" "javascript" "jq" "jsdoc" "json" "json5" "jsonc" "jsonnet" "julia" "just" "kconfig" "kdl" "kotlin" "koto" "kusto" "lalrpop" "latex" "ledger" "leo" "linkerscript" "liquid" "liquidsoap" "llvm" "lua" "luadoc" "luap" "luau" "m68k" "make" "markdown" "markdown_inline" "matlab" "menhir" "meson" "mlir" "muttrc" "nasm" "nginx" "nim" "nim_format_string" "ninja" "nix" "norg" "nqc" "nu" "objc" "objdump" "ocaml" "ocaml_interface" "ocamllex" "odin" "pascal" "passwd" "pem" "perl" "php" "php_only" "phpdoc" "pioasm" "po" "pod" "poe_filter" "pony" "powershell" "printf" "prisma" "problog" "prolog" "promql" "properties" "proto" "prql" "psv" "pug" "puppet" "purescript" "pymanifest" "python" "ql" "qmldir" "qmljs" "query" "r" "ralph" "rasi" "rbs" "re2c" "readline" "regex" "rego" "requirements" "rescript" "rnoweb" "robot" "robots" "roc" "ron" "rst" "ruby" "runescript" "rust" "scala" "scfg" "scss" "sflog" "slang" "slint" "smali" "smithy" "solidity" "soql" "sosl" "sourcepawn" "sparql" "sql" "squirrel" "ssh_config" "starlark" "strace" "styled" "supercollider" "superhtml" "surface" "svelte" "sway" "swift" "sxhkdrc" "systemtap" "t32" "tablegen" "tact" "tcl" "teal" "templ" "terraform" "textproto" "thrift" "tiger" "tlaplus" "tmux" "todotxt" "toml" "tsv" "tsx" "turtle" "twig" "typescript" "typespec" "typoscript" "typst" "udev" "ungrammar" "unison" "usd" "uxntal" "v" "vala" "vento" "verilog" "vhdl" "vhs" "vim" "vimdoc" "vrl" "vue" "wgsl" "wgsl_bevy" "wing" "wit" "xcompose" "xml" "xresources" "yaml" "yang" "yuck" "zathurarc" "zig" "ziggy" "ziggy_schema" ];
    overrides = {
      odin = p.odin.overrideAttrs (let 
        rev = "e8adc739b78409a99f8c31313f0bb54cc538cf73";
      in {
        version = "0.0.0+rev=${substring 0 7 rev}";
        src = pkgs.fetchFromGitHub {
          owner = "amaanq";
          repo = "tree-sitter-odin";
          inherit rev;
          hash = "sha256-vlw5XaHTdsgO9H4y8z0u0faYzs+L3UZPhqhD/IJ6khY=";
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
    nvim-treesitter-override
    nvim-treesitter-textobjects
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
        paths = nvim-treesitter-override.passthru.dependencies;
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
