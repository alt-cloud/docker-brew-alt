#!/bin/bash -exu
#
# Prep a docker-brew-alt branch
#

PROGDIR=$(dirname "$0")
PROGNAME=$(basename "$0")
[ "$PROGDIR" = "." ] && PROGDIR=$(pwd)

DATE=$(date +%Y%m%d)


temp_dir=
f_cleanup_temp_dir()
{
    [ -z "$temp_dir" ] || rm -rf -- "$temp_dir"
    exit "$@"
}

temp_dir=$(mktemp -dt "${0##*/}.XXXXXXXX")
trap 'f_cleanup_temp_dir $?' EXIT
trap 'exit 143' HUP QUIT PIPE TERM

f_ctrl_c() {
    printf "\n*** Exiting ***\n"
    exit $?
}
# trap int (ctrl-c)
trap f_ctrl_c SIGINT

f_arches_for_repo() {
    repo=$1
    if [ "$repo" = p8 ] || [ "$repo" = c8 ]
    then
        echo 'i586 x86_64'
    else
        echo 'i586 x86_64 aarch64'
    fi
}

f_help() {
    cat <<EOF

NAME
    ${PROGNAME}

SYNOPSIS
    ${PROGNAME} ALT_RELEASE

DESCRIPTION
    This is a script build new ve/docker

EXAMPLE
    ${PROGNAME} p8

EOF
}

uuidgen >/dev/null

ALT_RELEASE="${1-}"
if ! [[ "$ALT_RELEASE" =~ (p8|p9|c8|sisyphus) ]];
then
    printf "ERROR: ALT_RELEASE missing or invalid\n"
    f_help
    exit 1
fi

case "$ALT_RELEASE" in
    sisyphus) BRANDING=alt-sisyphus;;
    c8) BRANDING=alt-spserver;;
    *) BRANDING=alt-starterkit;;
esac

# Generate apt.conf and sources.list files
./gen-apt-files.sh "${temp_dir}/apt"

# Build the image
workspace_dir="${temp_dir}/workspace"
mkdir -p "$workspace_dir"
pushd "$workspace_dir"
out_dir="${temp_dir}/out"
mkdir -p "$out_dir"
    # git clone mkimage-profile
    git clone git://git.altlinux.org/people/mike/packages/mkimage-profiles.git

    # build image
    cd mkimage-profiles

    for arch in $(f_arches_for_repo "$ALT_RELEASE")
    do
        make \
        APTCONF="${temp_dir}/apt/apt.conf.${ALT_RELEASE}.${arch}" \
        CLEAN=1 \
        QUIET=1 \
        NICE=1 \
        IMAGEDIR="${workspace_dir}" \
        ARCH="${arch}" \
        BRANDING="$BRANDING" \
        "ve/docker.tar.xz"

        mkdir -p "${out_dir}/${arch}"
        mv "${workspace_dir}/docker-${DATE}-${arch}.tar.xz" "${out_dir}/${arch}/alt-${ALT_RELEASE}-${arch}-${DATE}.tar.xz"
        cat > ${out_dir}/${arch}/Dockerfile <<EOF
FROM scratch

MAINTAINER \\
[Alexey Shabalin <shaba@altlinux.org>] \\
[Mikhail Gordeev <obirvalger@altlinux.org]

ADD alt-${ALT_RELEASE}-${arch}-${DATE}.tar.xz /

RUN true > /etc/security/limits.d/50-defaults.conf

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
EOF

    done

popd &> /dev/null

# Create empty branch to avoid storing of many tarballs in git
branch_name="$ALT_RELEASE"
git branch -D "$branch_name" &>/dev/null ||:
export GIT_WORK_TREE="$out_dir"
git checkout --orphan "$branch_name"
git rm -r .

git add .
git commit -m "Update altlinux $ALT_RELEASE - $DATE"

git checkout master
