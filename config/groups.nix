{
  lib,
  ...
}: let
in lib.listToAttrs [
  # Gids 1337010000-1337019999 are reserved for usergroups to match uids
  # Gids 1337020000-1337029999 are used for groups here

  ({ name = "part";         value.gid = 1337020000; }) # Access to mounted disks & partitions
  ({ name = "pool";         value.gid = 1337020001; }) # Access to mounted pools
  ({ name = "media";        value.gid = 1337020002; }) # Access to shared media
  ({ name = "media-ro";     value.gid = 1337020003; }) # Access to shared media (read-only)
  ({ name = "vg";           value.gid = 1337020004; }) # Access to shared games
  ({ name = "vm";           value.gid = 1337020005; }) # Access to virtual machine images
  ({ name = "db";           value.gid = 1337020006; }) # Access to databases
  ({ name = "steam";        value.gid = 1337020007; }) # Access to shared steam libraries
  ({ name = "backup";       value.gid = 1337020008; }) # Access to global backups

  # sudo groupdel backup;
  # sudo groupdel vg; 
  # sudo groupdel steam; 
  # sudo groupdel vm; 
  # sudo groupdel db; 
  # sudo groupdel media-ro; 
  # sudo groupdel part; 
  # sudo groupdel pool; 
  # sudo groupdel media; 
  #
  # sudo groupadd -g 1337020000 part
  # sudo groupadd -g 1337020001 pool
  # sudo groupadd -g 1337020002 media
  # sudo groupadd -g 1337020003 media-ro
  # sudo groupadd -g 1337020004 vg
  # sudo groupadd -g 1337020005 vm
  # sudo groupadd -g 1337020006 db
  # sudo groupadd -g 1337020007 steam
  # sudo groupadd -g 1337020008 backup
]
