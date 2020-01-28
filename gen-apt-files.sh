#!/bin/sh -efu

# Generate apt.conf and sources.list files for some (listed below) arches and
# repositories. Save it in the directory `apt' by default, but it can be
# changed using firt command line argument.

ROOT="file:///space/ALT" # Place with ALT repositories
#ROOT="http://ftp.altlinux.org/pub/distributions/ALTLinux"
ARCHES="i586 x86_64 aarch64 ppc64le"
REPOS="p8 p9 Sisyphus"
APT_DIR="${1:-apt}"

mkdir -p "$APT_DIR"
APT_DIR="$(realpath "$APT_DIR")"
pushd "$APT_DIR" &> /dev/null

for ARCH in $ARCHES
do
    for REPO in $REPOS
    do
        REPO_NORM="$(echo "$REPO" | tr '[:upper:]' '[:lower:]')"
        cat > "$APT_DIR/apt.conf.${REPO_NORM}.${ARCH}" <<EOF
Dir::Etc::main "/dev/null";
Dir::Etc::parts "/var/empty";
Dir::Etc::SourceList "$APT_DIR/sources.list.${REPO_NORM}.${ARCH}";
Dir::Etc::SourceParts "/var/empty";
Dir::Etc::preferences "/dev/null";
Dir::Etc::preferencesparts "/var/empty";
EOF
        cat >  "$APT_DIR/sources.list.${REPO_NORM}.${ARCH}" <<EOF
rpm $ROOT/$REPO $ARCH classic
rpm $ROOT/$REPO noarch classic
EOF
    done
done

popd &> /dev/null
