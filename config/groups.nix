{
  lib,
  ...
}: let
in lib.listToAttrs [
  ({ name = "part";         value.gid = 1337010000; })
  ({ name = "pool";         value.gid = 1337010001; })
  ({ name = "media";        value.gid = 1337010002; })
  ({ name = "media-ro";     value.gid = 1337010003; })
  ({ name = "vg";           value.gid = 1337010004; })
  ({ name = "vm";           value.gid = 1337010005; })
  ({ name = "db";           value.gid = 1337010006; })
  ({ name = "steam";        value.gid = 1337010007; })
  ({ name = "backup";       value.gid = 1337010008; })

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
  # sudo groupadd -g 1337010000 part
  # sudo groupadd -g 1337010001 pool
  # sudo groupadd -g 1337010002 media
  # sudo groupadd -g 1337010003 media-ro
  # sudo groupadd -g 1337010004 vg
  # sudo groupadd -g 1337010005 vm
  # sudo groupadd -g 1337010006 db
  # sudo groupadd -g 1337010007 steam
  # sudo groupadd -g 1337010008 backup
]
