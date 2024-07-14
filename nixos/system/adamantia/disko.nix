{ disks ? [ "/dev/disk/by-id/does-not-exist2" ], lib, ... }:
let
  # Use folder name as name of this system
  system-name = builtins.baseNameOf ./.;

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
        # NOTE: Currently this is not considered by `disko` for descendants.
        #       This option needs to be dupped for each dataset individually.
        #       See: https://github.com/nix-community/disko/issues/703
        mountpoint = "legacy";
        canmount = "off";

        # Quota: 10% free + 5% free for metadata: prevent permanently
        # degrading/fragmenting pool due to low space available.
        # (the `zpool-luks-size` is of course partition size and not
        # ZFS available space)
        # Maybe 5% is a bit much for it but fine for now, decrease if
        # needed.
        quota = "${builtins.toString (zpool-luks-size * 0.85)}M";

        # Recordsize is the upper limit of logical block sizes.
        # Small files will get small blocks, large file will get up to this
        # value-sized blocks.
        # This is fine for most files in general as most of them are written
        # once, overwritten in whole and read in whole/as fast as possible or
        # written rarily and also in whole.
        # The crucial exceptions are: Virtual Machines, Databases and BitTorrents.
        # The first two use large single files and write to them often and in same
        # sizes (like 64K for KVM). This causes huge write amplification.
        # For BitTorrent clients on the other hand i'm not sure: it's either
        # they have have the same issue but only for reads (thus only relevant
        # for seeding and the read amplification is not as bad as write
        # anyway), or it's relevant for writes too, in which case the files
        # will be fragmented and separate download and finished datasets with
        # move after completion would be required.
        # NOTE: for SSDs, the fragmentation bit miight be not relevant and it's
        #       might be fine to just leave it 16K.
        # NOTE: this might be mitigated by disabling pre-allocation in the BT
        #       client.
        # NOTE: sequential download option might help (BT downloads random
        #       pieces by default).
        recordsize = "1M";

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
        zfs list -t snapshot -H -o name | grep -E '^${zpool-name}/${system-name}@blank$' || zfs snapshot ${zpool-name}/${system-name}@blank
        zfs list -t snapshot -H -o name | grep -E '^${zpool-name}/${system-name}/persist@blank$' || zfs snapshot ${zpool-name}/${system-name}/persist@blank

        # For the impermanence setup - to reset root every reboot.
        zfs list -t snapshot -H -o name | grep -E '^${zpool-name}/${system-name}/local@blank$' || zfs snapshot ${zpool-name}/${system-name}/local@blank

        # For the impermanence setup - to reset home every reboot.
        # (not for right now - let it be on root)
        #zfs list -t snapshot -H -o name | grep -E '^${zpool-name}/${system-name}/home@blank$' || zfs snapshot ${zpool-name}/${system-name}/home@blank
      ";

      # TODO: persist/impermanence
      # TODO: google tutorials. One of them had better solution, like local,
      #       persist and another one or something
      #       volatile datasets: zpool-name/local/NAME
      #           safe datasets: zpool-name/persist/NAME
      datasets = let
        # Helper with defaults
        mkZfsFs = args: lib.recursiveUpdate {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          options.compression = "zstd";
        } args;
      in {
        # We nuke this
        "${system-name}/local" = mkZfsFs {
          mountpoint = "/";
        };

        # We don't nuke that
        "${system-name}/nix" = mkZfsFs {
          mountpoint = "/nix";
        };
        "${system-name}/persist/data" = mkZfsFs {
          mountpoint = "/persist/data";
          options.recordsize = "1M";
        };
        "${system-name}/persist/log" = mkZfsFs {
          mountpoint = "/persist/log";
          #options.recordsize = "32K";
        };
        "${system-name}/persist/state" = mkZfsFs {
          mountpoint = "/persist/state";
        };
        "${system-name}/persist/cache" = mkZfsFs {
          mountpoint = "/persist/cache";
        };
        "${system-name}/persist/cred" = mkZfsFs {
          mountpoint = "/persist/cred";
        };
        # probably want zvols for docker & podman
        # (docker seem to shit gazillions of datasets,
        # podman doesn't support rootless... or does it?
        # apparently it does)
        # (TODO: test both ways anyway)
        "${system-name}/persist/state/var/lib/docker" = mkZfsFs {
          mountpoint = "/persist/state/var/lib/docker";
        };
        "${system-name}/persist/state/home/nrv/.local/state/containers" = mkZfsFs {
          mountpoint = "/persist/state/home/nrv/.local/state/containers";
        };
        # "${system-name}/persist/state/var/lib/docker" = {
        #   type = "zfs_volume";
        #   size = "10G";
        #   content = {
        #     type = "filesystem";
        #     format = "ext4";
        #     mountpoint = "/persist/state/var/lib/docker";
        #   };
        # };

        # ===

        # Impermanence draft

        # /
        # /home

        # /persist/{data,log,state,cache,cred} - different backup & preservation policies.
  
        # This category is all the important stuff.
        # All is either created by hand by me or manually saved.
        # This all pretty much should be backed up.
        # ---
        # /persist/data/home/nrv/desk (xdg-user-dir)
        # /persist/data/home/nrv/dl (xdg-user-dir)
        # /persist/data/home/nrv/pub (xdg-user-dir)
        # /persist/data/home/nrv/dox (xdg-user-dir)
        # /persist/data/home/nrv/mus (xdg-user-dir)
        # /persist/data/home/nrv/pix (xdg-user-dir)
        # /persist/data/home/nrv/vid (xdg-user-dir)
        # /persist/data/home/nrv/.local/share/templates (xdg-user-dir) (env var)
        # /persist/data/home/nrv/pr
        # /persist/data/home/nrv/dot
        # /persist/data/home/nrv/.config/nvim/spell (env vars)
        # /persist/data/home/nrv/.local/share/lyrics (env vars)

        # Logs are logs. Sucks to lose for a system that is in use, but nothing
        # critical. May backup for historical reasons. 
        # ---
        # /persist/log/nix/var/log
        # /persist/log/var/log
        # /persist/log/var/lib/systemd/coredump

        # State is something that i can throw out but restoring (recreating) it
        # will be a manual process.
        # (interactive application settings, live-service content
        # (steam games), browser history & bookmarks, etc.)
        # Some of this needs to be backed up granularly, like game saves and
        # browser history, for which it's isn't really feasible to create
        # separate bind mounts. On top of that i don't know what such category
        # should be called.
        # ---
        # /persist/state/var/lib/bluetooth
        # /persist/state/var/lib/nixos
        # /persist/state/var/lib/docker
        # /persist/state/var/lib/mlocate
        # /persist/state/home/nrv/.mozilla
        # /persist/state/home/nrv/.local/state/sandbox (env vars)
        # # this is a maybe (save them in config if permanent or bookmark the snapshot of it)
        # /persist/state/etc/NetworkManager/system-connections

        # Cache is something that can be thrown out carelessly and only hit
        # application performance as a result.
        # Stuff like `NODE_PATH` and `CARGO_TARGET_DIR` should also go there
        # if/when i figure it out (proper project sandboxing + separate dirs,
        # that is).
        # ---
        # /persist/cache/home/nrv/.cache

        # Self-explanatory.
        # ---
        # /persist/cred/etc/machine-id
        # /persist/cred/etc/ssh/moduli (?)
        # /persist/cred/etc/ssh/ssh_host_dsa_key
        # /persist/cred/etc/ssh/ssh_host_dsa_key.pub
        # /persist/cred/etc/ssh/ssh_host_ecdsa_key
        # /persist/cred/etc/ssh/ssh_host_ecdsa_key.pub
        # /persist/cred/etc/ssh/ssh_host_ed25519_key
        # /persist/cred/etc/ssh/ssh_host_ed25519_key.pub
        # /persist/cred/etc/ssh/ssh_host_rsa_key
        # /persist/cred/etc/ssh/ssh_host_rsa_key.pub
        # /persist/cred/home/nrv/.ssh
        # /persist/cred/home/nrv/.config/sops (env vars)
        # /persist/cred/home/nrv/.config/rclone (env vars)
        # /persist/cred/home/nrv/.local/share/pass (env vars)
        # /persist/cred/home/nrv/.local/share/gnupg (env vars)
        # /persist/cred/home/nrv/.local/share/rustu2f (env vars)

        # Maybe some of these? (persist & datasets)
        # /srv
        # /usr
        # /usr/local
        # /var
        # /var/games
        # /var/lib
        # /var/lib/AccountsService
        # /var/lib/NetworkManager
        # /var/lib/apt
        # /var/lib/dpkg
        # /var/log
        # /var/mail
        # /var/snap
        # /var/spool
        # /var/www
        # /home/user
        # /home/root

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
