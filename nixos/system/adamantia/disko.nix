{
  disks ? [ "/dev/disk/by-id/specify-disks-as-cli-arg" ],

  # Name of the pool.
  # Note that this gets interpolated into strings and scripts AS IS.
  # Be careful with names
  zpool-name ? "mythos",
  zpool-name-mount ? zpool-name,

  lib,

  # FIXME: WARNING: only works for `postCreateHook`. Does not affect `disko`'s
  # `rootMountPoint`. I don't know how to fix this
  rootMountPoint ? "/mnt",
  ...
}: let
  # Use folder name as name of this system
  system-name = builtins.baseNameOf ./.;

  # Size of your drive
  # 1 TeraByte is equal to:
  # - 0.90949470177292823792 TebiByte
  # - 931.322574615478515625 GibiByte
  # - 953674.31640625 MebiByte
  # - 976562500 KibiByte (actually a whole number)
  # - 1000000000000 Byte, of course
  # However, the actual number is bytes shown is 1000204886016,
  # which in turn evenly divides to 976762584 KiB but still not
  # evenly to MiB. Let's just count the total GiB count as 931,
  # which is only a bit less than the actual size, and be done 
  # with it:
  total-size = gibi 931;

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

  esp-size = gibi 4;
  boot-size = gibi 4;
  zpool-luks-size = gibi 600;
  #swap-size = gibi 2;

  # Layout

  # End positions are useless. It misaligns for 4096 (alignment is 512
  # instead).
  # I don't know why. But using `size` instead of `end` fixes the issue.

  # Start alignment offset -> zpool size.
  zpool-luks-start = start-offset-size+1;
  zpool-luks-end = start-offset-size + zpool-luks-size;

  # ESP size <- End alignment offset.
  esp-end = total-size - end-offset-size - 1;
  esp-start = esp-end - esp-size;

  # Boot size <- ESP size <- End alignment offset.
  boot-end = esp-start - 1;
  boot-start = boot-end - boot-size;

  # Some crap:
  # total-size = 50
  # end-offset-size = 5
  # esp-size = 10
  # boot-size = 20
  #
  # esp-end    = 50 - 5 - 1 = 44
  # esp-start  = 44 - 10 = 34
  #
  # boot-end   = 34 - 1 = 33
  # boot-start = 33 - 20 = 13
  # 1                                                50
  # ##################################################
  # -------------^-------------------^^---------^^----
  #         boot-start = 13          ||         ||
  #                                  ||         |offset = 5
  #                                  ||         esp-end = 44
  #                                  |esp-start = 35
  #                                  boot-end = 34 
in
  #assert zpool-luks-end < (total-size - boot-start);
builtins.trace ''

zpool-luks-start = "${builtins.toString zpool-luks-start}"
zpool-luks-end   = "${builtins.toString zpool-luks-end}"
esp-start        = "${builtins.toString esp-start}"
esp-end          = "${builtins.toString esp-end}"
boot-start       = "${builtins.toString boot-start}"
boot-end         = "${builtins.toString boot-end}"
''

{
  # NOTE: Without the "/persist".neededForBoot the permissions of user home
  #       folders and their nested contents created by impermanence is wrong
  #       (root). I've isolated this issue exactly to this, the other ones
  #       below without it didn't help. Without this line the mounts are weird
  #       and all over: /home/nrv/dox is mounted on
  #       `mythos/sys/adamantia/persist` for example, instead of
  #       `mythos/sys/adamantia/persist/data`.
  #       Also the same for `mythos/../persist/cred/etc/sops`, it ends up on
  #       `mythos/../persist` instead of `mythos/../persist/cred`.
  #       Disko seems to have a lot of such mount shadowing/wrong mount
  #       order/time-of-mount-time-of-usage issues with impermanence.
  #       Self: see 20240731174051-disko-impermanence-mount-order.md for
  #       `mount` command output
  # TODO: Report all this to disko & impermanence
  fileSystems."/persist".neededForBoot = true;

  fileSystems."/persist/data".neededForBoot = true;
  fileSystems."/persist/log".neededForBoot = true;
  fileSystems."/persist/state".neededForBoot = true;
  fileSystems."/persist/cache".neededForBoot = true;
  fileSystems."/persist/cred".neededForBoot = true;
  fileSystems."/".neededForBoot = true;
  # FIXME: enable this - probably needed for impermanence
  fileSystems."/home".neededForBoot = true;

  # FIXME: For some unimaginable reason `rootMountPoint` returns "" for the string  trace:
  #disko.rootMountPoint = lib.trace "${rootMountPoint}" rootMountPoint;
  disko.devices.disk.main = {
    # For debug mode
    # Equal to the usual 1TB hardware disk (mythos, dawnstar),
    # actually around 500 meg bigger than 1TB but still a lot
    # smaller than 1TiB.
    imageSize = "976762584K"; 

    type = "disk";
    name = zpool-name; # Primary pool on disk is always named the same as the disk
    device = builtins.head disks;
    content = {
      type = "gpt";
      partitions = {
        grub-mbr = {
          priority = 0;
          start = "1M";
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
            passwordFile = "/tmp/${zpool-name}.key";
            content = {
              type = "zfs";
              pool = "${zpool-name}";
            };
          };
        };
        # Legacy boot /boot: actually, maybe i'll make that later when i need it.
        # boot = {
        #   priority = 2;
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
        #     mountpoint = "/boot";
        #     mountOptions = [ "defaults" "noatime" ];
        #   };
        # };

        # For now i'll use only a single EFI partition
        ESP = {
          priority = 3;
          type = "EF00";
          start = "${builtins.toString esp-start}M";
          size = "${builtins.toString esp-size}M";
          #end = "${builtins.toString esp-end}M";
          name = "ESP";
          # bootable = true;
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "defaults" "noatime" "umask=0077" ];
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

  disko.devices.zpool = let
    # "nodiratime" as well just to be sure
    defaultMountOptions = [ "noatime" "nodiratime" ];
  in {
    ${zpool-name} = {
      type = "zpool";
      mode = ""; # "" is stripe/single drive

      # zpool options (`zpoolprops(7)`)
      options = {
        ashift = "12";
      };

      # `mount -o` for root dataset.
      mountOptions = defaultMountOptions;

      # This is inherited to everything below
      rootFsOptions = {
        # NOTE: Currently a value of 'legacy' is not considered by `disko` for
        #       descendants. This option needs to be dupped for each dataset
        #       individually. See: https://github.com/nix-community/disko/issues/703
        mountpoint = "/media/pool/${zpool-name}";
        # This is redundant with mountpoint=legacy but why not
        # XXX: And here we go... Attempted to set mountpoint for root dataset below,
        #      and got on `disko`'s check for this. Why it works like that with
        #      `legacy`? I don't know. definitely NOT what it does in ZFS
        #      (disables auto mount but still leaves mountpoint for children to
        #      inherit)
        #canmount = "off";

        # Quota: 10% free + 5% free for metadata: prevent permanently
        # degrading/fragmenting pool due to low space available.
        # (the `zpool-luks-size` is of course partition size and not
        # ZFS available space)
        # Maybe 5% is a bit much for it but fine for now, decrease if
        # needed.
        quota = "${builtins.toString (zpool-luks-size * 0.85)}M";

        # Recordsize is the upper limit of logical block sizes.
        # Small files will get small blocks, large file will get up to this
        # value-sized blocks. Writing more to small files also increase their block
        # size up to this recordsize, and single file's blocks are always the
        # same size.
        # Big values like 1M are fine for most files in general as most of them
        # are written once, overwritten in whole and read in whole/as fast as
        # possible or written rarily and also in whole.
        # However besides exceptions below you should still consider reading
        # parts of files, which will always read at least the current block
        # size bytes. This is relevant for file managers (that read embedded
        # file metadata) and for example if you scan your filesystem with
        # something like `find -type f | xargs file`.
        # The crucial exceptions are: Virtual Machines, Databases, BitTorrents
        # and log files:
        # - The last one just does a lot of small writes at the end of a
        # potentially large file.
        # - The first two use large single files and read & write to them often
        # and always in same sizes (like 64K for KVM). This causes huge read &
        # write amplification.
        # - For BitTorrent clients on the other hand i'm not sure: it's either
        # they have have the same issue but only for reads (thus only relevant
        # for seeding and the read amplification is not as bad as write
        # anyway), or it's relevant for writes too, in which case the
        # recordsize needs to match the BT chunk size (which is 16K the OpenZFS
        # docs suggest), and as a result the files will be 8/64 times more
        # fragmented as compared to 128k/1M record size, so a separate
        # 'download' and 'finished' datasets with automatic move after
        # completion would be required.
        # NOTE(BT): for SSDs, the fragmentation bit might be not relevant and
        #           it might be fine to just leave it a 16K.
        # NOTE(BT): write amplification might only be relevant if the BT client
        #           pre-allocates the files. Some (all?) of them can disable it for
        #           filesystems that support sparse files (which ZFS does).
        #           ...Now that i think of it more, it can't be. After first M
        #           (or whatever big recordsize it) is the file gets it will be
        #           the the same anyway.
        # NOTE(BT): sequential download option might help (BT downloads random
        #           pieces by default). Or might not. Depends on a definition
        #           of 'sequential' read. In case of a spinning hard drive, is
        #           it better to have the data fragmented but close and in
        #           order (if something else is written to the FS apart from
        #           the file while the download is in the process), or is it
        #           same as completely fragmented? Physically better. Actually?
        # NOTE: leave this to default because of reasons described at the start
        #       of this wall of comment, tune per-dataset below.
        # NOTE: Links:
        #       - https://old.reddit.com/r/zfs/comments/tmio9p/recordsize_1m_ok_for_generaluse_datasets_for_home/
        recordsize = "128K";

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

      # Mount the root dataset -- however it's directory is read-only and used
      # only to get to children datasets.
      mountpoint = "/media/pool/${zpool-name}";

      # Create snapshot of the initial empty state. This is free.
      postCreateHook = "
        # Just in case
        zfs list -t snapshot -H -o name | grep -E '^${zpool-name}/sys/${system-name}@blank$' || zfs snapshot ${zpool-name}/sys/${system-name}@blank
        ds_name='persist'; zfs list -t snapshot -H -o name | grep -E '^${zpool-name}/sys/${system-name}/$ds_name@blank$' || zfs snapshot ${zpool-name}/sys/${system-name}/$ds_name@blank
        ds_name='nix'; zfs list -t snapshot -H -o name | grep -E '^${zpool-name}/sys/${system-name}/$ds_name@blank$' || zfs snapshot ${zpool-name}/sys/${system-name}/$ds_name@blank

        # For the impermanence setup - to reset root every reboot.
        ds_name='local'; zfs list -t snapshot -H -o name | grep -E '^${zpool-name}/sys/${system-name}/$ds_name@blank$' || zfs snapshot ${zpool-name}/sys/${system-name}/$ds_name@blank

        # For the impermanence setup - to reset home every reboot.
        # (not for right now - let it be on root)
        ds_name='local/home'; zfs list -t snapshot -H -o name | grep -E '^${zpool-name}/sys/${system-name}/$ds_name@blank$' || zfs snapshot ${zpool-name}/sys/${system-name}/$ds_name@blank

        echo ==================
        echo CREATE HOOK
        df
        echo ==================

        echo PWD: $PWD
        ls -la /
      ";

      # This runs after EVERY SINGLE mount of every thing.
      # Moved to postAllMountsHook.nix
      postMountHook = "";

      datasets = let
        # Helper with defaults
        mkZfsFs = args: lib.recursiveUpdate {
          type = "zfs_fs";
          mountOptions = defaultMountOptions;

          options.compression = "zstd";
        } args;
        mkZfsFsLegacy = args: lib.recursiveUpdate (mkZfsFs {
          options.mountpoint = "legacy";
        }) args;
      in {
        # Systems toplevel dataset. Other toplevel datasets are at the end
        # below
        "sys" = mkZfsFsLegacy {
          # mountpoint = "/media/pool/${zpool-name}/sys";
        };
        # Root dataset of this system on this pool
        # (not to be confused with system's root, /, which is `local`)
        "sys/${system-name}" = mkZfsFsLegacy {
          # mountpoint = "/media/pool/${zpool-name}/sys/${system-name}";
        };

        # We nuke this
        "sys/${system-name}/local" = mkZfsFsLegacy {
          mountpoint = "/";
        };
        "sys/${system-name}/local/home" = mkZfsFsLegacy {
          mountpoint = "/home";
        };

        # We don't nuke that
        "sys/${system-name}/nix" = mkZfsFsLegacy {
          mountpoint = "/nix";

          # The files in /nix/store are literally never changed, only created
          # and deleted. They're also not really read in part, i think. So it's
          # totally fine
          options.recordsize = "1M";
        };
        "sys/${system-name}/persist" = mkZfsFsLegacy {
          mountpoint = "/persist";
          # options.mountpoint = "/media/pool/${zpool-name}/sys/${system-name}/persist";
        };
        "sys/${system-name}/persist/data" = mkZfsFsLegacy {
          mountpoint = "/persist/data";
          options.recordsize = "1M";
        };
        "sys/${system-name}/persist/log" = mkZfsFsLegacy {
          mountpoint = "/persist/log";
          #options.recordsize = "32K";
        };
        "sys/${system-name}/persist/state" = mkZfsFsLegacy {
          mountpoint = "/persist/state";
        };
        "sys/${system-name}/persist/cache" = mkZfsFsLegacy {
          mountpoint = "/persist/cache";
        };
        "sys/${system-name}/persist/cred" = mkZfsFsLegacy {
          mountpoint = "/persist/cred";
        };

        # for non-sandboxed steam
        "sys/${system-name}/persist/data/home/gamer" = mkZfsFsLegacy {
          mountpoint = "/persist/data/home/gamer";
        };

        # probably want zvols for docker & podman
        # (docker seem to shit gazillions of datasets,
        # podman doesn't support rootless... or does it?
        # apparently it does)
        # (TODO: test both ways anyhow)
        "sys/${system-name}/persist/state/var" = mkZfsFsLegacy {
          mountpoint = "/persist/state/var";
        };
        "sys/${system-name}/persist/state/var/lib" = mkZfsFsLegacy {
          mountpoint = "/persist/state/var/lib";
        };
        "sys/${system-name}/persist/state/var/lib/docker" = mkZfsFsLegacy {
          mountpoint = "/persist/state/var/lib/docker";
        };
        "sys/${system-name}/persist/state/home" = mkZfsFsLegacy {
          mountpoint = "/persist/state/home";
        };
        "sys/${system-name}/persist/state/home/nrv" = mkZfsFsLegacy {
          mountpoint = "/persist/state/home/nrv";
        };
        "sys/${system-name}/persist/state/home/nrv/.local" = mkZfsFsLegacy {
          mountpoint = "/persist/state/home/nrv/.local";
        };
        "sys/${system-name}/persist/state/home/nrv/.local/state" = mkZfsFsLegacy {
          mountpoint = "/persist/state/home/nrv/.local/state";
        };
        "sys/${system-name}/persist/state/home/nrv/.local/state/containers" = mkZfsFsLegacy {
          mountpoint = "/persist/state/home/nrv/.local/state/containers";
        };
        # TODO: maybe a sync=disabled tmpfs? https://github.com/Mic92/dotfiles/blob/b2ff14454465c10d00c4239eea0785583ddf9a35/nixos/eve/modules/disko.nix#L82

        # "sys/${system-name}/persist/state/var/lib/docker" = {
        #   type = "zfs_volume";
        #   size = "10G";
        #   content = {
        #     type = "filesystem";
        #     format = "ext4";
        #     mountpoint = "/persist/state/var/lib/docker";
        #   };
        # };

        # ===

        # Other toplevel persistent datasets

        "media" = mkZfsFs {
          mountpoint = "/media/pool/${zpool-name}/media";
          options.recordsize = "1M";
        };
        "media/store" = mkZfsFs {
          mountpoint = "/media/pool/${zpool-name}/media/store";
        };

        "vg" = mkZfsFs {
          mountpoint = "/media/pool/${zpool-name}/vg";
          options.recordsize = "1M";
        };
        "vg/steam" = mkZfsFs {
          mountpoint = "/media/pool/${zpool-name}/vg/steam";
          options.casesensitivity = "insensitive";
        };
        "vg/owned" = mkZfsFs {
          mountpoint = "/media/pool/${zpool-name}/vg/owned";
        };

        "db" = mkZfsFs {
          mountpoint = "/media/pool/${zpool-name}/db";
        };
        "vm" = mkZfsFs {
          mountpoint = "/media/pool/${zpool-name}/vm";
        };
        "bak" = mkZfsFs {
          mountpoint = "/media/pool/${zpool-name}/bak";
          options.compression = "off";
          options.recordsize = "1M";
        };

        # ===

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
