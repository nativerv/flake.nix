{ disks ? [ "/dev/vdb" ], ... }:
let
  # Name of the pool.
  # Note that this gets interpolated into strings and scripts AS IS.
  # Be careful with names, use [-a-z0-9].
  zpool-name = "shitpile";

  mebi = builtins.toString;
  gibi = n: builtins.toString (1024 * n);

  # Everything in the actual partitioning scheme below is in mebibytes.
  # Helper `gibi` available that multiplies accordingly.

  # Sizes

  # Alignment offset
  start-offset = mebi 1;
  # OpenZFS docs use 1G offset at the end... Why not?
  # I guess it does alignment as well and helps SSD not
  # suffer that much on 100% load.
  # (`disko` interprets negatives as going from the end)
  end-offset = gibi -1;

  esp-size = mebi 512;
  boot-size = gibi 4;
  zpool-luks-size = gibi 600;
  swap-size = gibi 2;

  # Layout

  # Start alignment offset -> zpool size.
  zpool-luks-start = start-offset;
  zpool-luks-end = start-offset + esp-size;

  # ESP size <- End alignment offset.
  esp-start = end-offset - esp-size;
  esp-end = end-offset;

  # Boot size <- ESP size <- End alignment offset.
  boot-start = esp-start - boot-size;
  boot-end = esp-start;
in
  assert zpool-luks-end < boot-start;
{
  disk = {
    main = {
      type = "disk";
      device = builtins.elemAt disks 0;
      content = {
        type = "table";
        format = "gpt";
        partitions = {
          grub-mbr = {
            size = "1M";
            type = "EF02"; # for grub MBR
          };
          ESP = {
            type = "EF00";
            name = "ESP";
            start = "${esp-start}M";
            end = "${esp-end}M";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot/efi";
              mountOptions = [ "defaults" ];
            };
          };
          boot = {
            type = "partition";
            name = "boot";
            start = "${boot-start}M";
            end = "${boot-end}M";
            bootable = true;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/boot";
              mountOptions = [ "defaults" "noatime" ];
            };
          };
          luks = {
            start = "${zpool-luks-start}M";
            end = "${zpool-luks-end}M";
            content = {
              type = "luks";
              name = "${zpool-name}-crypted";
              settings.allowDiscards = true;
              settings.bypassWorkqueues = true;
              passwordFile = "/tmp/secret.key";
              content = {
                type = "zfs";
                pool = "${zpool-name}";
              };
            };
          };

          # {
          #   name = "swap";
          #   type = "partition";
          #   start = "-${swap-size}M";
          #   end = "100%";
          #   part-type = "primary";
          #   content = {
          #     type = "swap";
          #     randomEncryption = true;
          #   };
          # }
        };
      };
    };
  };

  zpool = {
    ${zpool-name} = {
      type = "zpool";
      mode = ""; # "" is stripe/single drive

      # zpool options (`zpoolprops(7)`)
      options = {
        ashift = 12;
      };

      # This is inherited to everything below
      rootFsOptions = {
        # Means that ZFS won't mount the datasets automatically but NixOS will
        # using standard Unix facilities, read: the `mount` command
        mountpoint = "legacy";
        canmount = "off";

        # Disable compression. I think this should be handled per-dataset.
        compression = "off";

        # Reduce writes and increase performance significantly
        atime = "off";

        # Unicode in filenames stuff - compatibility & performance(?)
        normalization = "formD";

        # POSIX attributes - POSIX compliance and drastic performance
        # improvement.
        acltype = "posixacl";
        xattr = "sa";

        # `zfsprops(7)`: Consider setting dnodesize to auto if the dataset uses
        # the xattr=sa property setting and the workload makes heavy use of
        # extended attributes.  This may be applicable to SELinux-enabled
        # systems, Lustre servers, and Samba servers, for example.
        #dnodesize = "auto"; # default: "legacy"

        # Disable some Sun crap. I believe this is for their cronjobs or
        # whatever.
        # If you need auto-snapshots, use `sanoid`.
        "com.sun:auto-snapshot" = "false";
      };

      # Don't mount the root dataset - use child dataset for root.
      mountpoint = null;

      # Create snapshot of the initial empty state. This is free.
      postCreateHook = "
        # Just in case
        zfs list -t snapshot -H -o name | grep -E '^${zpool-name}@blank$' || zfs snapshot zroot@blank

        # For the impermanence setup - to root every reboot.
        zfs list -t snapshot -H -o name | grep -E '^root@blank$' || zfs snapshot ${zpool-name}/root@blank
      ";

      # TODO: persist/impermanence
      # TODO: google tutorials. One of them had better solution, like local,
      # persist and another one or something
      # volatile datasets: zpool-name/local/NAME
      #     safe datasets: zpool-name/persist/NAME
      datasets = {
        root = {
          type = "zfs_fs";
          mountpoint = "/";
          options.compression = "zstd";
        };
        home = {
          type = "zfs_fs";
          mountpoint = "/home";
          options.compression = "zstd";
        };
        docker = {
          type = "zfs_fs";
          mountpoint = "/var/lib/docker";
        };
        # zfs_legacy_fs = {
        #   type = "zfs_fs";
        #   options.mountpoint = "legacy";
        #   mountpoint = "/zfs_legacy_fs";
        # };
        # zfs_testvolume = {
        #   type = "zfs_volume";
        #   size = "10M";
        #   content = {
        #     type = "filesystem";
        #     format = "ext4";
        #     mountpoint = "/ext4onzfs";
        #   };
        # };
        # encrypted = {
        #   type = "zfs_fs";
        #   options = {
        #     mountpoint = "none";
        #     encryption = "aes-256-gcm";
        #     keyformat = "passphrase";
        #     keylocation = "file:///tmp/secret.key";
        #   };
        #   # use this to read the key during boot
        #   # postCreateHook = ''
        #   #   zfs set keylocation="prompt" "zroot/$name";
        #   # '';
        # };
        # "encrypted/test" = {
        #   type = "zfs_fs";
        #   mountpoint = "/zfs_crypted";
        # };
      };
    };
  };

}
