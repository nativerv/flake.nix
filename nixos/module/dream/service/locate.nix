{
  self ? null,
  ...
}:
{
  config ? null,
  pkgs ? null,
  lib ? null,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.service.locate;
  outputPath = "/var/lib/mlocate/mlocate.db";
in
{
  options.dream.service.locate = {
    enable = mkEnableOption "Enable service.locate - locate database";
  };
  config = mkIf cfg.enable {
    # This setups an SSH server. Very important if you're setting up a headless system.
    # TODO: hardening
    services.locate = {
      enable = true;
      package = pkgs.mlocate.overrideAttrs (prev: {
        makeFlags = prev.makeFlags ++ [
          "dbfile=${outputPath}"
        ];
      });
    
      interval = "never";
      output = outputPath;
      localuser = null; # INFO: unsupported by mlocate, "null" to suppress warning
      # extraFlags = [
      #   "--verbose"
      # ];
      prunePaths = [
        "/nix/store"
        "/nix/var/log/nix"
        "/tmp"
        "/run"
        "/mnt"

        "/var/run"
        "/var/tmp"
        "/var/cache"
        "/var/lock"
        "/var/spool"

        "/afs"
        "/net"
        "/sfs"
        "/udev"

        "/media/all"

        # FIXME(dream: option): use customizible persist path from `dream.archetype.impermanent` here?
        "/persist"

        # FIXME(dream: option): use customizible old path from `dream.archetype.???` (zfs config) here?
        "/old"
      ];
      pruneFS = [
        # exclude "fuse" cuz veracrypt is matched by that
        "afs"
        "anon_inodefs"
        "auto"
        "autofs"
        "bdev"
        "binfmt"
        "binfmt_misc"
        "ceph"
        "cgroup"
        "cgroup2"
        "cifs"
        "coda"
        "configfs"
        "cramfs"
        "cpuset"
        "curlftpfs"
        "debugfs"
        "devfs"
        "devpts"
        "devtmpfs"
        "ecryptfs"
        "eventpollfs"
        "exofs"
        "futexfs"
        "ftpfs"
        "fusectl"
        "fusesmb"
        "fuse.ceph"
        "fuse.glusterfs"
        "fuse.gvfsd-fuse"
        "fuse.mfs"
        "fuse.rclone"
        "fuse.rozofs"
        "fuse.sshfs"
        "gfs"
        "gfs2"
        "hostfs"
        "hugetlbfs"
        "inotifyfs"
        "iso9660"
        "jffs2"
        "lustre"
        "lustre_lite"
        "misc"
        "mfs"
        "mqueue"
        "ncpfs"
        "nfs"
        "NFS"
        "nfs4"
        "nfsd"
        "nnpfs"
        "ocfs"
        "ocfs2"
        "pipefs"
        "proc"
        "ramfs"
        "rpc_pipefs"
        "securityfs"
        "selinuxfs"
        "sfs"
        "shfs"
        "smbfs"
        "sockfs"
        "spufs"
        "sshfs"
        "subfs"
        "supermount"
        "sysfs"
        "tmpfs"
        "tracefs"
        "ubifs"
        "udev"
        "udf"
        "usbfs"
        "vboxsf"
        "vperfctrfs"
      ];
    };
  };
}

