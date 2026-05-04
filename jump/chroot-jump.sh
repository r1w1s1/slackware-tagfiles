#!/bin/bash
set -euo pipefail
# Define constants
CHROOT_DIR="${CHROOT_DIR:-/home/r1w1s1/chroot-jump}"
PACKAGE_DIR="${PACKAGE_DIR:-/home/r1w1s1/slackware64}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKGLIST_FILE="${SCRIPT_DIR}/package_list.txt"
usage() {
    echo "Usage: sudo $0 {create|access|delete}"
    exit 1
}
[ $# -eq 1 ] || usage
ACTION="$1"
create_chroot() {
    echo "[*] Creating chroot at: $CHROOT_DIR"
    echo "[*] Using packages from: $PACKAGE_DIR"
    mkdir -p "$CHROOT_DIR"
    if [ ! -f "$PKGLIST_FILE" ]; then
        echo "ERROR: Package list not found: $PKGLIST_FILE"
        exit 1
    fi
    echo "[*] Reading package list..."
    PKGS=()
    while read -r line; do
        [ -z "$line" ] && continue
        series="${line%%/*}"
        pkg="${line##*/}"
        match=$(find "$PACKAGE_DIR/$series" -name "$pkg-*.t?z" | head -n 1)
        if [ -n "$match" ]; then
            PKGS+=("$match")
        else
            echo "WARNING: Not found: $line"
        fi
    done < "$PKGLIST_FILE"
    echo "[*] Installing ${#PKGS[@]} packages..."
    for pkgfile in "${PKGS[@]}"; do
        /sbin/installpkg --terse --root "$CHROOT_DIR" "$pkgfile"
    done
    echo "[*] Mounting virtual filesystems..."
    mount -t proc none "$CHROOT_DIR/proc"
    mount --rbind /dev "$CHROOT_DIR/dev"
    mount --rbind /sys "$CHROOT_DIR/sys"
    echo ">> Updating CA certificates"
    chroot "$CHROOT_DIR" /usr/sbin/update-ca-certificates --fresh
    echo "[*] Copying /etc/slackpkg/mirrors into chroot..."
    mkdir -p "$CHROOT_DIR/etc/slackpkg"
    cp /etc/slackpkg/mirrors "$CHROOT_DIR/etc/slackpkg/mirrors"
    echo "[+] Chroot environment is ready."
}
access_chroot() {
    echo "[*] Entering chroot: $CHROOT_DIR"
    chroot "$CHROOT_DIR" /bin/bash --login
}
delete_chroot() {
    echo "[*] Cleaning up chroot at: $CHROOT_DIR"
    umount -l "$CHROOT_DIR/proc" || true
    umount -l "$CHROOT_DIR/dev" || true
    umount -l "$CHROOT_DIR/sys" || true
    if mountpoint -q "$CHROOT_DIR/proc" || mountpoint -q "$CHROOT_DIR/dev" || mountpoint -q "$CHROOT_DIR/sys"; then
        echo "ERROR: Filesystems still mounted under $CHROOT_DIR. Aborting."
        exit 1
    fi
    rm -rf "$CHROOT_DIR"
    echo "[+] Deleted chroot environment."
}
case "$ACTION" in
    create) create_chroot ;;
    access) access_chroot ;;
    delete) delete_chroot ;;
    *) usage ;;
esac
