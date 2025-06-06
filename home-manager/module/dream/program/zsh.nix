{
  self,
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
  cfg = config.dream.program.zsh;

  homeDir = config.home.homeDirectory;
  configHome = config.xdg.configHome;

  # ZDOTDIR - full path
  zDotDir = "${homeDir}/${dotDir}";

  # ZDOTDIR - relative to home
  dotDir =
    if hasPrefix homeDir configHome
    then "${removePrefix homeDir configHome}/zsh"
    else "";

  # FIXME: overridden by `exports`
  # histSize = (pow 2 31) - 1;

  # Where to put plugins
  pluginsDir = "${dotDir}/plugins.d";

  # Bring plugin commits that i've used
  # Will source name.plugin.zsh
  # TODO: audit
  plugins = [
    rec {
      name = "zsh-autosuggestions";
      src = pkgs.fetchFromGitHub {
        inherit name;
        owner = "zsh-users";
        repo = name;
        rev = "a411ef3e0992d4839f0732ebeb9823024afaaaa8";
        sha256 = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
      };
    }
    rec {
      # will source zsh-autosuggestions.plugin.zsh
      name = "zsh-syntax-highlighting";
      src = pkgs.fetchFromGitHub {
        inherit name;
        owner = "zsh-users";
        repo = name;
        rev = "dffe304567c86f06bf1be0fce200077504e79783";
        sha256 = "sha256-3G6c6uOqYTp2WmfmwJ5qIYsnhSLF2UZ3iyCNEpdjjzc=";
      };
    }
    rec {
      name = "zsh-autopair";
      src = pkgs.fetchFromGitHub {
        inherit name;
        owner = "hlissner";
        repo = name;
        rev = "9d003fc02dbaa6db06e6b12e8c271398478e0b5d";
        sha256 = "sha256-hwZDbVo50kObLQxCa/wOZImjlH4ZaUI5W5eWs/2RnWg=";
      };
    }
    rec {
      name = "zsh-completions";
      src = pkgs.fetchFromGitHub {
        inherit name;
        owner = "zsh-users";
        repo = name;
        rev = "d4511c23659381b56dec8be8c8553b7ff3dc5fd8";
        sha256 = "sha256-OOMabAhRcgs7YpCx+g6yIqTHDMwMueBD+s7P+WCdHPk=";
      };
    }
    # rec {
    #   name = "zsh-system-clipboard";
    #   src = pkgs.fetchFromGitHub {
    #     inherit name;
    #     owner = "kutsan";
    #     repo = name;
    #     rev = "0f05d015b0dd8ba5f0fce2aafbf4e3c54b4bbec1";
    #     sha256 = "sha256-1QC2PjMvsaXWbiVJMxBGM9mCoEHdWzs8GH0stnnP2Nc=";
    #
    #     nativeBuildInputs = [ pkgs.wl-clipboard ];
    #   };
    # }
  ];
in {
  options.dream.program.zsh = {
    enable = mkEnableOption "Enable program.zsh";
  };
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.programs.zsh.enable;
        message = "The module `program.zsh` is incompatible with Home Manager's `programs.zsh`";
      }
    ];

    # TODO(hardcoded): remove this from global env
    home.packages = with pkgs; [
      # For RPROMPT
      bc
      # unbuffer: for git in `aliases`
      expect
    ];

    # TODO(dream): dream.appearance.devicons or something like that which
    #              toggles devicons across system

    home.file = mkMerge [
      # Core Zsh stuff
      {
        # This is file at $HOME is required in vanilla Zsh
        ".zshenv".text = ''source "${zDotDir}/.zshenv"'';

        # Load Home Manager stuff and set the ZDOTDIR so that the rest runs from
        # it.
        "${dotDir}/.zshenv".text = ''
          # Environment variables
          . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"

          # Only source this once
          if [[ -z "$__HM_ZSH_SESS_VARS_SOURCED" ]]; then
            export __HM_ZSH_SESS_VARS_SOURCED=1
          fi

          export ZDOTDIR='${zDotDir}'
        '';

        # Runs the main rc file of my config
        "${dotDir}/.zshrc".text = ''source "$ZDOTDIR/rc"'';
      }

      # Install plugins
      (mkMerge
        (map (plugin: { "${pluginsDir}/${plugin.name}".source = plugin.src; })
        plugins))

      # Install my config files
      # Which is uglier?
      # (mkMerge (mapAttrsToList (name: _: { "${dotDir}/${name}".source = ./zsh/${name}; }) (builtins.readDir ./zsh)))
      (pipe (builtins.readDir ./zsh) [
        # Read dir & convert to HM .source's basically
        (mapAttrsToList (name: _: {
          "${dotDir}/${name}".source = ./zsh/${name};
        }))
        mkMerge
      ])
    ];
  };
}
