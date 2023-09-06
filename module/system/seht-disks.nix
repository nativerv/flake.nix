{ disks ? [ "/dev/vdb" ], ... }:
let
  # Some variables
  vg-name = "shitpile";

  # Everything's in megabytes
  start-offset = builtins.toString (1);
  efi-size = builtins.toString (1024 * 0.5);
  boot-size = builtins.toString (1024 * 1);
  root-size = builtins.toString (1024 * 10);
  # home size is the 100%FREE
  swap-size = builtins.toString (1024 * 2);

  efi-start = start-offset;
  efi-end = start-offset + efi-size;
  boot-start = efi-end;
  boot-end = boot-start + boot-size;
  lvm-start = boot-end;
  lvm-end = -swap-size;
in {
  disk = {
    vdb = {
      type = "disk";
      device = builtins.elemAt disks 0;
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            type = "partition";
            name = "ESP";
            start = "${efi-start}M";
            end = "${efi-end}M";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot/efi";
              mountOptions = [ "defaults" ];
            };
          }
          {
            type = "partition";
            name = "boot";
            start = "${boot-start}M";
            end = "${boot-end}M";
            bootable = true;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/boot";
              mountOptions = [ "defaults" "relatime" ];
            };
          }
          {
            type = "partition";
            name = vg-name;
            content = {
              type = "lvm_pv";
              vg = vg-name;
            };
          }
          {
            name = "swap";
            type = "partition";
            start = "-${swap-size}M";
            end = "100%";
            part-type = "primary";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          }
        ];
      };
    };
  };
  lvm_vg = {
    ${vg-name} = {
      type = "lvm_vg";
      lvs = {
        root = {
          type = "lvm_lv";
          size = "${root-size}M";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            mountOptions = [ "rw" "relatime" ];
          };
        };
        home = {
          type = "lvm_lv";
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/home";
            mountOptions = [ "rw" "relatime" ];
          };
        };
      };
    };
  };
}
