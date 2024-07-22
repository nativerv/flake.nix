{
  rootMountPoint,
  zpool-name,
  pkgs ? import <nixpkgs> {},
}: let
  groups = import ./../../../config/groups.nix { inherit (pkgs) lib; };
  gids = builtins.mapAttrs (k: v: builtins.toString v.gid) groups;
in with gids; pkgs.writeShellScriptBin "disko-post-all-mounts" ''
  # Disk mountpoints directory
  # TODO: configure this in impermanence or systemd-tmpfiles or something

  location='${rootMountPoint}/media/disk'
  chmod o-rwx "$location"
  setfacl -bk "$location"
  setfacl -m group:${part}:rwx "$location"

  location='${rootMountPoint}/media/disk/part'
  chmod o-rwx "$location"
  setfacl -bk "$location"
  setfacl -m group:${part}:rwx "$location"

  # Pool mountpoints directory
  # TODO: configure this in impermanence or systemd-tmpfiles or something
  location='${rootMountPoint}/media/pool'
  chmod o-rwx "$location"
  setfacl -bk "$location"
  setfacl -m group:${pool}:rwx "$location"

  # Root of the pool - read-only
  location='${rootMountPoint}/media/pool/${zpool-name}'
  chmod o-rwx "$location"
  setfacl -bk "$location"
  setfacl -m group:${pool}:rx "$location"

  # Media
  location='${rootMountPoint}/media/pool/${zpool-name}/media'
  location2='${rootMountPoint}/media/pool/${zpool-name}/media/store'
  chmod o-rwx "$location" "$location2"
  setfacl -m default:group:${media}:rwx,group:${media}:rwx,default:group:${media-ro}:rx,group:${media-ro}:rx,default:other:--- "$location" "$location2"
  
  # Videogames
  chmod o+rx '${rootMountPoint}/media/pool/${zpool-name}/vg'

  location='${rootMountPoint}/media/pool/${zpool-name}/vg/steam'
  chmod o-rwx "$location"
  setfacl -bk "$location"
  setfacl -m default:group:${steam}:rwx,group:${steam}:rwx,default:other:--- "$location"

  location='${rootMountPoint}/media/pool/${zpool-name}/vg/owned'
  chmod o-rwx "$location"
  setfacl -bk "$location"
  setfacl -m default:group:${vg}:rwx,group:${vg}:rwx,default:other:--- "$location"

  # Virtual machines
  location='${rootMountPoint}/media/pool/${zpool-name}/vm'
  chmod o-rwx "$location"
  setfacl -bk "$location"
  setfacl -m default:group:${vm}:rwx,group:${vm}:rwx,default:other:--- "$location"

  # Databases
  location='${rootMountPoint}/media/pool/${zpool-name}/db'
  chmod o-rwx "$location"
  setfacl -bk "$location"
  setfacl -m default:group:${db}:rwx,group:${db}:rwx,default:other:--- "$location"

  # Backups
  location='${rootMountPoint}/media/pool/${zpool-name}/bak'
  chmod o-rwx "$location"
  setfacl -bk "$location"
  setfacl -m default:group:${backup}:rwx,group:${db}:rwx,default:other:--- "$location"
''
