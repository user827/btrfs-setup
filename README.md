Backup setup for btrfs filesystem.

# Requires

* btrfs filesystem for /
* /home to be in a separate subvolume

# Setup


- Install package
```
makepkg --install --syncdeps
```
- Configure `/media/remote_backup` and `/media/btrfsroot` in fstab and check
  they are mounted.
- systemctl enable --now backup-btrbk@daily.timer
- systemctl enable --now backup-btrbk@hourly.timer
- systemctl enable --now backup-hourly@<group>.timer
- Also enable and start btrfs-scrub@.timer, -resume and -balance service.

The following paths inside home should be in separate subvolumes to prevent their
backup:
- repobig
- .local/share/Steam
- Videos
- builds

# Setup snapshots and indexing without backups
- Configure `/etc/big_backup.conf`.
- Make .snapshots directory be pruned by mlocate.
- systemctl enable --now backup-daily-bigdata.timer
- systemctl enable --now backup-hourly-bigdata.timer
