#!/bin/sh
set -eu

. /etc/big_backup.conf

umask 077
for dataroot in $BTRFS_BIGDATA; do
  mountpoint -q "$dataroot" || { echo "$dataroot: not mounted" >&2; continue; }

  if grep -q "$dataroot.*\sro[\s,]" /proc/mounts; then
    echo "$dataroot: ro" >&2
    continue
  fi

  dstcontents=$(printf %s\\n "$dataroot" | tr / _)
  tmpcontents=${dstcontents}.tmp
  trap 'rm -f "$tmpcontents"' 0
  locate -r ^"$dataroot" > "$tmpcontents"
  # Too noisy, and not really any more secure
  #find "$dataroot" \( -type d -name '.snapshots' -prune \) -o \( -type f -ls \) > "$tmpcontents"
  mv "$tmpcontents" "$CONTENTSDIR/$dstcontents"
done
