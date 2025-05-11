{
  self ? null,
  ...
}:
{
  config ? null,
  lib ? null,
  pkgs ? null,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.archetype.minimal;
in
{
  options.dream.archetype.minimal = {
    enable = mkEnableOption "Enable archetype.minimal";
  };
  config = mkIf cfg.enable {
    # oom daemon - out of memory process killer
    systemd.oomd.enable = mkDefault false;

    environment.shellAliases = {
      ls = null;
      ll = null;
      l = null;
    };

    # environment.systemPackages = lib.mkForce (with pkgs; [
    #   # acl
    #   # attr
    #   bashInteractive # bash with ncurses support
    #   # bzip2
    #   coreutils-full
    #   # cpio
    #   # curl
    #   # diffutils
    #   # findutils
    #   # gawk
    #   # stdenv.cc.libc
    #   # getent
    #   # getconf
    #   # gnugrep
    #   # gnupatch
    #   # gnused
    #   # gnutar
    #   # gzip
    #   # xz
    #   # less
    #   # libcap
    #   # ncurses
    #   # netcat
    #   # config.programs.ssh.package
    #   # mkpasswd
    #   # procps
    #   # su
    #   # time
    #   # util-linux
    #   # which
    #   # zstd
    # ]);

    # disable default not strictly necessary packages - nano, perl, etc
    environment.defaultPackages = [];

    documentation = {
      enable = mkDefault false;
      man = {
        enable = mkDefault false;
      };
      dev.enable = mkDefault false; 
      doc.enable = mkDefault false; 
      info.enable = mkDefault false; 
      nixos = {
        enable = mkDefault false;
      };
    };
  };
}
