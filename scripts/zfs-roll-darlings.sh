#!/bin/sh

set -u
# set -x
set +e

max=10

zfs destroy -r "${pool}/sys/${system}/local.boot.${max}"

for n in $(seq 2 "${max}" | sort -rn); do
  n_prev="$(printf '%02d\n' "$((n-1))")"
  n="$(printf '%02d\n' "${n}")"
  zfs rename "${pool}/sys/${system}/local.boot.${n_prev}" "${pool}/sys/${system}/local.boot.${n}" &&
    zfs set mountpoint="/old/boot.${n}" "${pool}/sys/${system}/local.boot.${n}" &&
    zfs set canmount='noauto' "${pool}/sys/${system}/local.boot.${n}" 
done

zfs snapshot "${pool}/sys/${system}/local@boot"
zfs rename "${pool}/sys/${system}/local" "${pool}/sys/${system}/local.boot.01"
zfs set readonly='on' "${pool}/sys/${system}/local.boot.01"
zfs set mountpoint="/old/boot.01" "${pool}/sys/${system}/local.boot.01"
zfs set canmount='noauto' "${pool}/sys/${system}/local.boot.01" 
zfs clone "${pool}/sys/${system}/local.boot.01@blank" "${pool}/sys/${system}/local"
zfs promote "${pool}/sys/${system}/local"
