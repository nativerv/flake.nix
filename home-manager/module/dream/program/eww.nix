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
  cfg = config.dream.program.eww;
  package = cfg.package;
in {
  options.dream.program.eww = {
    enable = mkEnableOption "Enable eww - widget engine - statusbar & more";

    package = mkOption {
      type = types.package;
      default = pkgs.eww;
      defaultText = literalExpression "pkgs.eww";
      example = literalExpression "pkgs.eww";
      description = ''
        The eww package to install.
      '';
    };
  };
  config = mkIf cfg.enable {
    programs.eww = {
      enable = true;
      configDir = ./eww;
      inherit package;
    };
    systemd.user.services = let
      sandboxing = {
        NoNewPrivileges = "yes";
        ProtectKernelTunables = "yes";
        ProtectControlGroups = "yes";
        LockPersonality = "true";
        MemoryDenyWriteExecute = "true";
        PrivateUsers = "true";
        RestrictNamespaces = "true";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
      };
    in {
      eww = with pkgs; {
        Unit = {
          Description = "ElKowar Widgets daemon";
          Documentation = "https://github.com/elkowar/eww";
          After = [ "graphical-session.target" ];
          Requisite = [ "graphical-session.target" ];
        };

        Install.WantedBy = [ "graphical-session.target" ];

        Service = sandboxing // {
          Type = "exec";
          ExecStart = ''${package}/bin/eww daemon --no-daemonize'';
          Restart = "always";
          # Allocate more CPU time for it - mitigate freezes.
          Nice = -10;
          # Prevent swapping - mitigate freezes.
          MemorySwapMax = 0;
          Environment = [
            # FIXME(hardcoded): dependencies assume my statusbar & Hyprland
            "PATH=${lib.makeBinPath [
              coreutils
              bash
              jq
              socat
              hyprland
              gnugrep
              gawk

              self.packages.${system}.statusbar-scripts
            ]}"
          ];
        };
      };
      # FIXME(hardcoded): this widget assumes Hyprland
      # TODO(dream): assert dream.program.hyprland or generalize
      eww-open-statusbar = with pkgs; {
        Unit = {
          Description = "Eww - Dream Statusbar";
          Documentation = "https://github.com/nativerv/dream.nix";
          After = [
            "eww.service"
            "hyprland-session.target"
          ];
          Requisite = [
            "eww.service"
            "hyprland-session.target"
          ];
        };

        Install.WantedBy = [ "hyprland-session.target" ];

        Service = sandboxing // {
          Type = "oneshot";
          ExecStart = ''
            ${package}/bin/eww open statusbar
          '';
          # NOTE: this always runs, insta closing the statusbar
          # ExecStop = writeShellScript "eww-stop" ''
          #   ${package}/bin/eww close statusbar
          #   ${coreutils}/bin/sleep 1
          # '';
        };
      };
    };
  };
}
