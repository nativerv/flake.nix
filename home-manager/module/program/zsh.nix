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
  homeDir = config.home.homeDirectory;
  configHome = config.xdg.configHome;

  inherit (config.programs.zsh) dotDir;

  # FIXME: overridden by `exports`
  histSize = (pow 2 31) - 1;
in {
  # TODO(hardcoded): remove this from global env
  home.packages = with pkgs; [
    # For RPROMPT
    bc
    # unbuffer: for git in `aliases`
    expect
  ];

  # TODO(dream): dream.appearance.devicons or something like that which
  #              toggless devicons across system
  home.file."${dotDir}/aliases".source = ./zsh/aliases;
  home.file."${dotDir}/colors".source = ./zsh/colors;
  home.file."${dotDir}/exports".source = ./zsh/exports;
  home.file."${dotDir}/functions".source = ./zsh/functions;
  home.file."${dotDir}/hooks".source = ./zsh/hooks;
  home.file."${dotDir}/keybindings".source = ./zsh/keybindings;
  home.file."${dotDir}/options".source = ./zsh/options;
  home.file."${dotDir}/prompt".source = ./zsh/prompt;
  home.file."${dotDir}/rc".source = ./zsh/rc;
  home.file."${dotDir}/vim_mode".source = ./zsh/vim_mode;
  programs.zsh = {
    enable = true;

    # Directory where ZSH looks for it's config files, e.g. .zshrc.
    dotDir =
      if hasPrefix homeDir configHome
      then "${removePrefix homeDir configHome}/zsh"
      else "";

    history = {
      size = histSize;
      save = histSize;
      path = "${config.xdg.stateHome}/zsh/history";
      extended = true;
    };

    initExtra = ''source "$ZDOTDIR/rc"'';

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
  };
}
