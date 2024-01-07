# Maintainer: me

pkgname=btrfs-setup
pkgver=1.0.0.r5.gcfd6c60
pkgrel=1
pkgdesc='Btrfs backups and scrubs'
license=('Apache')
url="https://github.com/user827/$pkgname.git"
arch=('any')
depends=(btrfs-progs shlib btrbk compsize)
optdepends=(smtp-forwarder)
backup=('etc/big_backup.conf' 'etc/btrbk/btrbk.conf')
source=("$pkgname::git+file://$PWD?signed")
validpgpkeys=(D47AF080A89B17BA083053B68DFE60B7327D52D6) # user827
sha256sums=(SKIP)

install=$pkgname.install

pkgver() {
  cd "$pkgname"
  git describe | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g'
}

package() {
  cd "$pkgname"

  mkdir -p "$pkgdir"/usr/bin
  install -m755 bin/* "$pkgdir"/usr/bin/

  mkdir -p "$pkgdir"/usr/lib/$pkgname
  install -m644 lib/$pkgname.sh "$pkgdir"/usr/lib/$pkgname
  install -m755 lib/*.sh "$pkgdir"/usr/lib/$pkgname

  install -D -m644 etc/big_backup.conf "$pkgdir"/etc/big_backup.conf
  install -D -m644 etc/btrbk.conf "$pkgdir"/etc/btrbk/btrbk.conf

  mkdir -p "$pkgdir"/usr/lib/systemd
  cp -r systemd "$pkgdir"/usr/lib/systemd/system
  chmod u=wrX,og=rX "$pkgdir"/usr/lib/systemd/system
}

# vim: filetype=PKGBUILD
