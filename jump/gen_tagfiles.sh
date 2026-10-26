#!/bin/sh
# Generate Slackware tagfiles from package_list.txt.
#
# Usage:
#   ./gen_tagfiles.sh /path/to/slackware64-current/slackware64
#
# The source tree is used as the package inventory.  Every package listed as
# series/package in package_list.txt is written as ADD; every other package
# found in the source tree is written as SKP.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PACKAGE_LIST=${PACKAGE_LIST:-"$SCRIPT_DIR/package_list.txt"}
SLACKWARE_TREE=${SLACKWARE_TREE:-/home/r1w1s1/slackware-mirrors/slackware/slackware64-current/slackware64}
SOURCE_TREE=${1:-$SLACKWARE_TREE}
OUTPUT_DIR=${2:-"$SCRIPT_DIR"}

usage() {
    echo "Usage: $0 SLACKWARE_TREE [OUTPUT_DIR]" >&2
    echo "Example: $0 /home/user/slackware64-current/slackware64" >&2
    exit "${1:-1}"
}

case "${1:-}" in
    -h|--help) usage 0 ;;
esac

[ -n "$SOURCE_TREE" ] || usage
[ -f "$PACKAGE_LIST" ] || {
    echo "ERROR: package list not found: $PACKAGE_LIST" >&2
    exit 1
}
[ -d "$SOURCE_TREE" ] || {
    echo "ERROR: Slackware tree not found: $SOURCE_TREE" >&2
    exit 1
}

tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/slackware-tagfiles.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM

# Convert a Slackware package filename into its unversioned package name.
# Slackware package names end in -VERSION-ARCH-BUILD.ext.
package_name() {
    file=$1
    case "$file" in
        *.txz) file=${file%.txz} ;;
        *.tgz) file=${file%.tgz} ;;
        *.tbz) file=${file%.tbz} ;;
        *) return 1 ;;
    esac

    printf '%s\n' "$file" | awk -F- '
        NF > 3 {
            for (i = 1; i <= NF - 3; i++) {
                if (i > 1) printf "-"
                printf "%s", $i
            }
            printf "\n"
            next
        }
        { print }
    '
}

series='a ap d e f k kde l n t tcl x xap xfce y'

for group in $series; do
    source_dir=$SOURCE_TREE/$group
    [ -d "$source_dir" ] || continue

    mkdir -p "$tmpdir/$group"
    output=$tmpdir/$group/tagfile

    find "$source_dir" -maxdepth 1 -type f \( \
        -name '*.txz' -o -name '*.tgz' -o -name '*.tbz' \
    \) -print |
    sort |
    while IFS= read -r package_file; do
        package=$(package_name "${package_file##*/}")
        entry=$group/$package
        if grep -Fqx "$entry" "$PACKAGE_LIST"; then
            printf '%s:ADD\n' "$package"
        else
            printf '%s:SKP\n' "$package"
        fi
    done > "$output"

    mkdir -p "$OUTPUT_DIR/$group"
    mv "$output" "$OUTPUT_DIR/$group/tagfile"
done

# Report requested packages that were not found in the source tree.  They are
# not silently turned into ADD entries because the installer cannot install a
# package that is not present in its package source.
grep -vE '^[[:space:]]*(#|$)' "$PACKAGE_LIST" |
while IFS= read -r entry; do
    case "$entry" in
        */*)
            group=${entry%%/*}
            package=${entry#*/}
            if [ ! -f "$OUTPUT_DIR/$group/tagfile" ] ||
                ! grep -Fqx "$package:ADD" "$OUTPUT_DIR/$group/tagfile"; then
                echo "WARNING: package not found in source tree: $entry" >&2
            fi
            ;;
        *)
            echo "WARNING: invalid package list entry: $entry" >&2
            ;;
    esac
done

echo "Generated tagfiles in: $OUTPUT_DIR"
