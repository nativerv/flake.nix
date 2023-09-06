{ ... }:

{
  # oom daemon - out of memory process killer
  systemd.oomd.enable = false;

  # disable default not strictly necessary packages - nano, perl, etc
  environment.defaultPackages = [];
}
