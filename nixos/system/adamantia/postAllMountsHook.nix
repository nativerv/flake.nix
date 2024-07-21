{
  rootMountPoint,
  zpool-name,
  pkgs ? import <nixpkgs> {},
}: pkgs.writeShellScriptBin "disko-post-all-mounts" "
  echo ==================
  echo MOUNT HOOK
  df
  echo ==================

  # Disk mountpoints directory
  # TODO: configure this in impermanence or systemd-tmpfiles or something

  #setfacl -bk '${rootMountPoint}/media/disk'
  #setfacl -m group:part:rwx '${rootMountPoint}/media/disk'

  #setfacl -bk '${rootMountPoint}/media/disk/part'
  #setfacl -m group:part:rwx '${rootMountPoint}/media/disk/part'

  # Pool mountpoints directory
  # TODO: configure this in impermanence or systemd-tmpfiles or something
  setfacl -bk '${rootMountPoint}/media/pool'
  setfacl -m group:pool:rwx '${rootMountPoint}/media/pool'

  # Root of the pool - read-only
  setfacl -bk '${rootMountPoint}/media/pool/${zpool-name}'
  setfacl -m group:pool:rx '${rootMountPoint}/media/pool/${zpool-name}'

  # Media
  setfacl -m default:group:media:rwx,group:media:rwx,default:group:media-ro:rx,group:media-ro:rx \\
    '${rootMountPoint}/media/pool/${zpool-name}/media'
  
  # Videogames
  chmod o+rx '${rootMountPoint}/media/pool/${zpool-name}/vg'

  setfacl -bk '${rootMountPoint}/media/pool/${zpool-name}/vg/steam'
  setfacl -m default:group:steam:rwx,group:steam:rwx '${rootMountPoint}/media/pool/${zpool-name}/vg/steam'

  setfacl -bk '${rootMountPoint}/media/pool/${zpool-name}/vg/owned'
  setfacl -m default:group:vg:rwx,group:vg:rwx '${rootMountPoint}/media/pool/${zpool-name}/vg/owned'

  # Virtual machines
  setfacl -bk '${rootMountPoint}/media/pool/${zpool-name}/vm'
  setfacl -m default:group:vm:rwx,group:vm:rwx '${rootMountPoint}/media/pool/${zpool-name}/vm'

  # Databases
  setfacl -bk '${rootMountPoint}/media/pool/${zpool-name}/db'
  setfacl -m default:group:db:rwx,group:db:rwx '${rootMountPoint}/media/pool/${zpool-name}/db'

  # Backups
  setfacl -bk '${rootMountPoint}/media/pool/${zpool-name}/bak'
  setfacl -m default:group:backup:rwx,group:db:rwx '${rootMountPoint}/media/pool/${zpool-name}/bak'
"
