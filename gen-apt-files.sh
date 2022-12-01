#!/bin/sh -efu

# Generate apt.conf and sources.list files for some (listed below) arches and
# repositories. Save it in the directory `apt' by default, but it can be
# changed using firt command line argument.

APT_DIR="${1:-apt}"
BRANCH_WORD= # Branch word: "" or "/branch"
ROOT="${2:-copy:/space/ALT}" # Place with ALT repositories
#ROOT="http://ftp.altlinux.org/pub/distributions/ALTLinux"
# Use not empty ADD_BRANCH for some repos such as ftp
ADD_BRANCH="${3-}" # Add /branch to url
ARCHES="i586 x86_64 aarch64 ppc64le armh"
REPOS="c8 p8 p9 p10 Sisyphus"

mkdir -p "$APT_DIR"
APT_DIR="$(realpath "$APT_DIR")"
pushd "$APT_DIR" &> /dev/null

for ARCH in $ARCHES
do
    for REPO in $REPOS
    do
        REPO_NORM="$(echo "$REPO" | tr '[:upper:]' '[:lower:]')"
        if [ -n "$ADD_BRANCH" ]; then
            if [ "$REPO" = Sisyphus ]; then
                BRANCH_WORD=
            else
                BRANCH_WORD=/branch
            fi
        fi
        cat > "$APT_DIR/apt.conf.${REPO_NORM}.${ARCH}" <<EOF
Dir::Etc::main "/dev/null";
Dir::Etc::parts "/var/empty";
Dir::Etc::SourceList "$APT_DIR/sources.list.${REPO_NORM}.${ARCH}";
Dir::Etc::SourceParts "/var/empty";
Dir::Etc::preferences "/dev/null";
Dir::Etc::preferencesparts "/var/empty";
EOF
        cat >  "$APT_DIR/sources.list.${REPO_NORM}.${ARCH}" <<EOF
rpm $ROOT/$REPO$BRANCH_WORD $ARCH classic
rpm $ROOT/$REPO$BRANCH_WORD noarch classic
EOF
    done
done

popd &> /dev/null
