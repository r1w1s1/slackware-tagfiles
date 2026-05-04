#!/bin/sh
grep -H ADD */tagfile | sed 's/:ADD$//' | sed 's|/tagfile:|/|' | sort > package_list.txt

#generate a lxc_package_list.txt(dont need kernel packages)
#grep -H ADD */tagfile | sed 's|.*/tagfile:||; s|:ADD$||' | grep -v '^kernel-' | sort > lxc_package_list.txt

