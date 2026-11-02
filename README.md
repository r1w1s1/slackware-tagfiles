# Slackware Tagfiles

Package selections for building a smaller Slackware jump VM.

## Global tagfile

The package selection is maintained in:

```text
jump/global_tagfile
```

Use one unversioned package per line, including its series:

```text
a/bash
a/coreutils
ap/htop
n/curl
n/openssh
```

Blank lines and lines beginning with `#` are ignored.

On a 64-bit Slackware installation medium, place the file at:

```text
slackware64/global_tagfile
```

The installer checks for a usable global tagfile in this order:

```text
1. /tmp/global_tagfile
2. slackware64/global_tagfile
```

Therefore, `/tmp/global_tagfile` can override the copy on read-only
installation media. Listed packages are installed; all other packages are
skipped. Without a usable global tagfile, the installer's normal behavior is
unchanged.

Choose `full` or `terse` in the installer when using the global tagfile.

## Generate per-series tagfiles

The project can also generate traditional per-series tagfiles from the same
selection:

```sh
cd jump
./gen_tagfiles.sh /path/to/slackware64-current/slackware64
```

Package versions are not included, so the selection remains valid across
Slackware updates.

## Build a custom ISO

Copy the global tagfile into the local Slackware tree and build the ISO from
that tree:

```sh
cp jump/global_tagfile \
  /path/to/slackware64-current/slackware64/global_tagfile

ISOONLY=yes /path/to/mirror-slackware-current-rsync.sh -i -o DVD
```

The installer image must contain global tagfile support. Current Slackware
installer images include this support. The official documentation is available
at:

```text
https://mirrors.slackware.com/slackware/slackware64-current/slackware64/README.global_tagfile
```

## Chroot testing

```sh
cd jump
sudo ./chroot-jump.sh create
sudo ./chroot-jump.sh access
sudo ./chroot-jump.sh delete
```

## Project

https://codeberg.org/r1w1s1/slackware-tagfiles
