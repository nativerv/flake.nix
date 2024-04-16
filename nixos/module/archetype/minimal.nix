{ ... }:
{
  lib ? null,
  pkgs ? null,
  ...
}:
{
  # oom daemon - out of memory process killer
  systemd.oomd.enable = false;

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
}
