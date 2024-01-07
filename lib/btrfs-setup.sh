### Functions

. /usr/lib/shlib.sh

nl='
'


# dets only one of the devices in case of there being multiple
getdevs() {
  local dev hdds=
  # grep -v automount
  local path="$1" mountdev
  mountdev=$(findmnt -nvo SOURCE --target "$path" | grep -v '^systemd-')
  if [ -h "$mountdev" ]; then
    mountdev=$(readlink "$mountdev")
  fi
  mountdev=${mountdev##*/}

  # shhh!
  for dev in /sys/fs/btrfs/*/devices/*; do
    bn=${dev##*/}
    if [ "$bn" = "$mountdev" ]; then
      uuid=${dev#/sys/fs/btrfs/}
      uuid=${uuid%/devices/*}
      break
    fi
  done

  for dev in /sys/fs/btrfs/"$uuid"/devices/*; do
    dev=${dev##*/}
    #hdparm -q -S 240 -y "$_RET"
    getslaves /sys/block/"$dev"/slaves
    if [ -n "$hdds" ]; then
      hdds="$hdds$nl$_RET"
    else
      hdds=$_RET
    fi
  done
  _RET=$hdds
}

getslaves() {
  local slavespath="$1"
  local devs=
  for dev in "$slavespath"/*; do
    dev=${dev##"$slavespath"/}
    case "$dev" in
      dm-*)
        slavespath=${slavespath}/$dev/slaves
        getslaves "$slavespath"
        if [ -n "$devs" ]; then
          devs="$devs$nl$_RET"
        else
          devs=$_RET
        fi
        ;;
      *)
        # empty line in case of not a partition
        dev=$(lsblk -no pkname /dev/"$dev" | grep -v '^$' | head -1)
        if [ -n "$devs" ]; then
          devs="$devs$nl$dev"
        else
          devs=$dev
        fi
        ;;
    esac
    _RET=$devs
  done
}

issleeping() {
  local dev devs
  devs=$1
  local ret=0
  _RET=0
  local IFS="$nl"
  for dev in $devs; do
    smartctl -n standby -q errorsonly /dev/"$dev" || ret=$?
    if [ "$ret" = 2 ]; then
      _RET=2
      return 0
    else
      [ "$_RET" != 0 ] || _RET=$ret
    fi
  done
}


btrfs_env_from_subvol() {
  BTRFS_SUBVOL="$1"
  #Snapshot directories for the subvols.
  SUBVOL_LOCAL_SNAP=$BTRFS_LOCAL_SNAPSHOTS/$BTRFS_SUBVOL
  SUBVOL_REMOTE_SNAP=$BTRFS_REMOTE_SNAPSHOTS/$BTRFS_SUBVOL
}

fail_clean() {
  [ -n "${SUBVOL_LOCK:-}" ] && subvol_unlock
  fail "$@"
}


subvol_delete_remote() {
  local snapname="$1"
  #subvol_get_remoteid "$snapname"
  #local "subvolid=$_RET"
  #[ -n "$subvolid" ] || return 1
  #btrfs qgroup destroy 0/$subvolid $BTRFS_REMOTE_MOUNTPOINT
  btrfs subvolume delete "$SUBVOL_REMOTE_SNAP/$snapname"
}

subvol_get_remoteid() {
  _RET=$(btrfs subvol list "$BTRFS_REMOTE_MOUNTPOINT" | awk "\$9 == \"${SUBVOL_REMOTE_SNAP#"$BTRFS_REMOTE_MOUNTPOINT"/}/$1\" { print \$2 }")
}


subvol_delete_local() {
  local "snapname=$1"
  #subvol_get_localid "$snapname"
  #local "subvolid=$_RET"
  #[ -n "$subvolid" ] || return 1
  #btrfs qgroup destroy 0/$subvolid $BTRFS_LOCAL_MOUNTPOINT
  btrfs subvolume delete "$SUBVOL_LOCAL_SNAP/$snapname"
}

subvol_get_localid() {
  _RET=$(btrfs subvol list "$BTRFS_LOCAL_MOUNTPOINT" | awk "\$9 == \"${SUBVOL_LOCAL_SNAP#"$BTRFS_LOCAL_MOUNTPOINT"/}/$1\" { print \$2 }")
}

# TODO ok?
# vim:set ft=sh
