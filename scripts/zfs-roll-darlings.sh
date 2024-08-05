#!/bin/sh

set -u
# set -x
set +e

max=10
local_dataset="${pool}/sys/${system}/local"
now_dataset="${local_dataset}/now"
old_dataset="${local_dataset}/old"
old_boots_dataset="${old_dataset}/boot"

zfs create -up \
  -o mountpoint="/old" \
  -o canmount='noauto' \
  "${old_dataset}"

zfs create -up \
  "${old_boots_dataset}"

# "mythos/sys/adamantia/local/now"
# "mythos/sys/adamantia/local/old/boot/01"
# "mythos/sys/adamantia/local/old/boot/02"
# "mythos/sys/adamantia/local/old/boot/03"

# Roll out the oldest / dataset
zfs destroy -r "${old_boots_dataset}/${max}"

# Shift all the other old / datasets
for n in $(seq 2 "${max}" | sort -rn); do
  n_prev="$(printf '%02d\n' "$((n-1))")"
  n="$(printf '%02d\n' "${n}")"
  zfs rename -u "${old_boots_dataset}/${n_prev}" "${old_boots_dataset}/${n}"
done

# Then, we first snapshot the state of current / dataset.
zfs snapshot "${now_dataset}@boot"
# Then move the current / to be boot/01 (older datasets were shifted by the
# loop above - the name boot/01 is free)
zfs rename -u "${now_dataset}" "${old_boots_dataset}/01"
# Then set it readonly - because it's basically a snapshot and should never be
# modified. The whole `clone` setup is made specifically because ZFS can't have
# never snapshots than the one you rolling back to.
zfs set readonly='on' "${old_boots_dataset}/01"
# Reset mountpoint on the old one - so it can be inherited and auto-mounted.
zfs inherit mountpoint "${old_boots_dataset}/01"
zfs umount "${old_boots_dataset}/01"

# Clone the @blank to be a new /
zfs clone "${old_boots_dataset}/01@blank" "${now_dataset}"
# Umount it so it doesn't get in the way

# Promote it because why not
zfs promote "${now_dataset}"
