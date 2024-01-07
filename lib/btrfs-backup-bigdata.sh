#!/bin/sh
set -eu

. /etc/big_backup.conf
. /usr/lib/btrfs-setup/btrfs-setup.sh

for dataroot in $BTRFS_BIGDATA; do
  mountpoint -q "$dataroot" || { echo "$dataroot: not mounted" >&2; continue; }

  getdevs "$dataroot"
  issleeping "$_RET"
  if [ "$_RET" = 2 ]; then
    echo "$dataroot: standby" >&2
    continue
  elif [ "$_RET" != 0 ]; then
    exit "$_RET"
  fi

  if grep -q "$dataroot.*\sro[\s,]" /proc/mounts; then
    echo "$dataroot: ro" >&2
    continue
  fi

  bckdir="$dataroot"/.snapshots

  [ -d "$bckdir" ] || mkdir -v "$bckdir"

  # should be run hourly
  [ -d "$bckdir"/old ] && btrfs subvol delete "$bckdir"/old >/dev/null
  [ -d "$bckdir"/latest ] && mv "$bckdir"/latest "$bckdir"/old
  btrfs subvol snapshot -r "$dataroot" "$bckdir"/latest >/dev/null
done
