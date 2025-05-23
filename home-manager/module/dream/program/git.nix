{
  self,
  flake,
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
  cfg = config.dream.program.git;
in
{
  options.dream.program.git = {
    enable = mkEnableOption "Enable program.git";
  };
  config = mkIf cfg.enable {
    programs.git.enable = true;
    programs.git.package = pkgs.gitFull;
    programs.git.extraConfig = {
      core = {
        autocrlf = false;
        filemode = false;
        pager = ''${pkgs.delta}/bin/delta --pager cat --true-color always --color-only'';
        find-renames = true;
      };
      alias = {
        # FIXME(bring): whatthecommit
        yolo = ''!command -v whatthecommit 2>/dev/null >&2 && git commit -m "$(whatthecommit)"'';
      };
      status = {
        showUntrackedFiles = "all";
      };
      interactive = {
        diffFilter = "${pkgs.delta}/bin/delta --true-color always --color-only";
      };
      user = {
        signingKey = fromJSONIfUnlockedOr (
          warn "Repo is not unlocked! Git won't sign your commits" null
        ) "${flake}/sus/nrv/eval/git/signing-key.json";
      };
      commit = {
        gpgSign = true;
      };
      rebase = {
        gpgSign = true;
      };
      tag = {
        gpgSign = true;
      };
      diff = {
        conflictstyle = "diff3";
      };
      diff = {
        colorMoved = "default";
      };
      # credential = {
      #   helper = "store";
      # };
      delta = {
        features = "collared-trogon";
      };
      "delta \"collared-trogon\"" = {
        # author: https://github.com/clnoll;
        commit-decoration-style = "bold box ul";
        dark = true;
        # file-decoration-style = none;
        # file-style = omit;
        # hunk-header-decoration-style = "#022b45" box ul;
        # hunk-header-file-style = "#999999";
        # hunk-header-line-number-style = bold "#003300";
        # hunk-header-style = file line-number syntax;
        # line-numbers = true;
        # line-numbers-left-style = "#022b45";
        # line-numbers-minus-style = "#80002a";
        # line-numbers-plus-style = "#003300";
        # line-numbers-right-style = "#022b45";
        # line-numbers-zero-style = "#999999";
        # minus-emph-style = normal "#80002a";
        # minus-style = normal "#331021";
        minus-style = ''syntax "#330011"'';
        # plus-emph-style = syntax "#003300";
        plus-style = ''syntax "#053f20"'';
        # plus-style = syntax "#0a4818";
        syntax-theme = "OneHalfDark";
        zero-style = "#a5a7b8";
        color-only = true;
      };
      
      "mergetool \"fugitive\"" = {
        # FIXME(hardcoded): nvim editor
        cmd = ''nvim -f -c "G diff" "$MERGED"'';
      };
      
      merge = {
        tool = "fugitive";
      };
      
      rerere = {
        enabled = true;
      };
      
      init = {
        defaultBranch = "master";
      };
    };
  };
}
