#!/bin/sh
set -eu

. /usr/lib/shlib.sh

fs=$1


pause_balance() {
  # might have exited already
  # might not be ours...
  btrfs balance pause "$fs" || true

  wait
  trap - TERM
  kill -TERM 0
}

# returns 1 when balance is in progress
status=$(btrfs balance status "$fs") || true
case "$status" in
  *running*)
    notice_sd "Not starting balance of $fs: already running"
    exit 0
    ;;
  *)
    notice_sd "Balancing $fs"
    trap 'pause_balance' TERM
    # & to be trappable
    btrfs balance start -dusage=85 -musage=50 "$fs" &
    wait || warn_sd 'balance failed' # || for enospace
    ;;
esac
