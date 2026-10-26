# Slackware-tagfiles Project

Custom Slackware tagfiles for building a smaller "jump" VM.

The `jump/` profile is intended for DevOps/jumpbox usage: SSH, shell tools,
Python, Git, curl/wget, Kubernetes tools, and general troubleshooting.

Package list: [`jump/package_list.txt`](jump/package_list.txt)

The package list is the source of truth.  Keep one unversioned package per
line, in the form `series/package`, for example:

```text
a/bash
ap/htop
n/curl
```

Generate the complete tagfiles from a Slackware package tree with:

```sh
cd jump
./gen_tagfiles.sh /path/to/slackware64-current/slackware64
```

Packages present in `package_list.txt` become `ADD`; all other packages found
in the Slackware tree become `SKP`.  The generated tagfiles remain in `jump/`
and are the files copied into the ISO tree.  Package versions should not be
put in `package_list.txt`, so the list does not need to change for every
Slackware update.

The normal workflow is therefore:

1. Edit only `jump/package_list.txt`.
2. Run `jump/gen_tagfiles.sh` against the Slackware package tree.
3. Copy the generated tagfile directories into the ISO tree.

Do not edit the generated `tagfile` files by hand.  The generator includes
every package present in the mirror, including new packages, and marks
unlisted packages as `SKP`.

> Note: `/home/r1w1s1` is only an example path from my machine. Replace it with your own home directory.

## Building a Custom ISO

Download AlienBOB's Slackware mirror script:

```sh
wget http://www.slackware.com/~alien/tools/mirror-slackware-current.sh -O /usr/local/bin/mirror-slackware-current.sh
chmod +x /usr/local/bin/mirror-slackware-current.sh
```

Mirror the Slackware tree:

```sh
RELEASE="current" SLACKROOTDIR="/home/r1w1s1/slackware-mirrors/slackware" ISO="NONE" sudo mirror-slackware-current.sh -f
```

Copy the custom tagfiles into the Slackware tree:

```sh
sudo mkdir /home/r1w1s1/slackware-mirrors/slackware/slackware64-current/custom-tagfiles
cd jump
./gen_tagfiles.sh /home/r1w1s1/slackware-mirrors/slackware/slackware64-current/slackware64
sudo cp -a a ap d e f k kde l n t tcl x xap xfce y \
  /home/r1w1s1/slackware-mirrors/slackware/slackware64-current/custom-tagfiles
```

Generate the ISO:

```sh
RELEASE="current" SLACKROOTDIR="/home/r1w1s1/slackware-mirrors/slackware" ISOONLY="yes" mirror-slackware-current.sh
```

## Installation

At **PACKAGE SERIES SELECTION**, press Enter.

![PACKAGE SERIES SELECTION](slackware-tagfile1.png)

At **SELECT PROMPTING MODE**, choose **tagpath**.

Do not choose **full**: that mode installs every package in the selected
series and does not apply the custom `ADD`/`SKP` selection.

![SELECT PROMPTING MODE](slackware-tagfile2.png)

Enter the custom tagfiles path:

```text
/var/log/mount/custom-tagfiles
```

![TAGPATH](slackware-tagfile3.png)

For network configuration, choose **DHCP** (default).

NetworkManager may appear in the installer, but it is not used by this profile.

## Chroot Testing

The `jump/chroot-jump.sh` script can test the same package set inside a local chroot.

```sh
cd jump
sudo ./chroot-jump.sh create
sudo ./chroot-jump.sh access
sudo ./chroot-jump.sh delete
```

By default, it uses:

```text
/home/r1w1s1/slackware64
```

Replace this with your own local Slackware mirror path.

## More Info

- https://www.slackbook.org/html/package-management-making-tags-and-tagfiles.html
- https://www.slackwiki.com/Tagfile_Install

## Mirror Site

https://codeberg.org/r1w1s1/slackware-tagfiles
