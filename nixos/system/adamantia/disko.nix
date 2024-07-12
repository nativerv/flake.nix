{ disks ? [ "/dev/disk/by-id/does-not-exist2" ], lib, ... }:
let
  # Name of the pool.
  # Note that this gets interpolated into strings and scripts AS IS.
  # Be careful with names
  zpool-name = "shitpile";

  # Size of your drive
  total-size = tebi 1;

  # Everything in the actual partitioning scheme below is in mebibytes.
  # Use the following helpers
  mebi = lib.id;
  gibi = n: 1024 * mebi n;
  tebi = n: 1024 * gibi n;

  # Sizes

  # Alignment offset
  start-offset-size = mebi 1;
  # OpenZFS docs use 1G offset at the end... Why not?
  # I guess it helpes with alignment as well and maybe helps SSD not
  # suffer that much on 100% load.
  end-offset-size = gibi 1;

  esp-size = mebi 512;
  boot-size = gibi 4;
  zpool-luks-size = gibi 600;
  #swap-size = gibi 2;

  # Layout

  # Start alignment offset -> zpool size.
  zpool-luks-start = start-offset-size+1;
  zpool-luks-end = start-offset-size + zpool-luks-size;

  # # ESP size <- End alignment offset.
  # esp-start = total-size - end-offset-size - esp-size;
  # esp-end = total-size - end-offset-size;
  #
  # # Boot size <- ESP size <- End alignment offset.
  # boot-start = esp-start - boot-size;
  # boot-end = esp-start;
in
  #assert zpool-luks-end < (total-size - boot-start);
{
  disko.devices.disk = lib.genAttrs disks (device: {
    type = "disk";
    name = lib.replaceStrings [ "/" ] [ "_" ] device;
    inherit device;
    content = {
      type = "gpt";
      partitions = {
        grub-mbr = {
          priority = 0;
          #start = "1M";
          #end = "${builtins.toString start-offset-size}M";
          size = "${builtins.toString start-offset-size}M";
          type = "EF02"; # for grub MBR
        };
        luks = {
          priority = 1;
          start = "${builtins.toString zpool-luks-start}M";
          # end = "${builtins.toString zpool-luks-end}M";
          size = "${builtins.toString zpool-luks-size}M";
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
        # ESP = {
        #   priority = 3;
        #   type = "EF00";
        #   start = "${builtins.toString esp-start}M";
        #   size = "${builtins.toString esp-size}M";
        #   #end = "${builtins.toString esp-end}M";
        #   name = "ESP";
        #   # bootable = true;
        #   content = {
        #     type = "filesystem";
        #     format = "vfat";
        #     mountpoint = "/boot/efi";
        #     mountOptions = [ "defaults" ];
        #   };
        # };
        # boot = {
        #   priority = 4;
        #   name = "boot";
        #   start = "${builtins.toString boot-start}M";
        #   size = "${builtins.toString boot-size}M";
        #   #end = "${builtins.toString boot-end}M";
        #   # bootable = true;
        #   content = {
        #     type = "filesystem";
        #     format = "ext4";
        #     mountpoint = "/boot";
        #     mountOptions = [ "defaults" "noatime" ];
        #   };
        # };

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
  });

  disko.devices.zpool = {
    ${zpool-name} = {
      type = "zpool";
      mode = ""; # "" is stripe/single drive

      # zpool options (`zpoolprops(7)`)
      options = {
        ashift = "12";
      };

      # This is inherited to everything below
      rootFsOptions = {
        # Means that ZFS won't mount the datasets automatically but NixOS will
        # using standard Unix facilities, read: the `mount` command
        mountpoint = "legacy";
        canmount = "off";

        # Compression should be handled per-dataset with none by default
        compression = "off";

        # Reduce writes and increase performance significantly
        atime = "off";

        # Unicode in filenames... stuff - compatibility & performance(?)
        normalization = "formD";

        # POSIX attributes - POSIX compliance and drastic performance
        # improvement
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
        zfs list -t snapshot -H -o name | grep -E '^${zpool-name}@blank$' || zfs snapshot ${zpool-name}@blank

        # For the impermanence setup - to reset root every reboot.
        zfs list -t snapshot -H -o name | grep -E '^${zpool-name}/root@blank$' || zfs snapshot ${zpool-name}/root@blank

        # For the impermanence setup - to reset home every reboot.
        zfs list -t snapshot -H -o name | grep -E '^${zpool-name}/home@blank$' || zfs snapshot ${zpool-name}/home@blank
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
          options.mountpoint = "legacy";
          options.compression = "zstd";
        };
        home = {
          type = "zfs_fs";
          mountpoint = "/home";
          options.mountpoint = "legacy";
          options.compression = "zstd";
        };
        docker = {
          type = "zfs_fs";
          mountpoint = "/var/lib/docker";
          options.mountpoint = "legacy";
          options.compression = "zstd";
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
