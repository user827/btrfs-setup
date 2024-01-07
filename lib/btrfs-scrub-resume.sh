#!/bin/sh
set -eu

. /usr/lib/shlib.sh

fs=$1

count=0
while ! status=$(btrfs scrub status -d "$fs") && [ "$count" -lt 3 ]; do
  sleep 10
  count=$((count + 1))
done

case "$status" in
  *aborted*|*interrupted*)
    if grep -q "$fs.*\sro[\s,]" /proc/mounts; then
      notice_sd "Resuming scrub of $fs (ro)"
      btrfs scrub resume -Br "$fs"
    else
      notice_sd "Resuming scrub of $fs"
      btrfs scrub resume -B "$fs"
    fi
    notice_sd 'Total stats:'
    btrfs scrub status -d "$fs"
    ;;
  "")
    echo "Could not get status of $fs" >&2
    exit 1
    ;;
  *)
    ;;
esac
