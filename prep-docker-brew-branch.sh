#!/bin/bash -xe
#
# Prep a docker-brew-alt branch
#

PROGDIR=$(dirname "$0")
PROGNAME=$(basename "$0")
[ "$PROGDIR" = "." ] && PROGDIR=$(pwd)

DATE=$(date +%Y%m%d)


f_ctrl_c() {
    printf "\n*** Exiting ***\n"
    exit $?
}
# trap int (ctrl-c)
trap f_ctrl_c SIGINT

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

f_clean_docker_images ()
{
    for i in $(sudo docker images -f 'dangling=true' -q);
    do
        sudo docker rmi $i;
    done
}

ALT_RELEASE="${1-}"
if ! [[ "$ALT_RELEASE" =~ (p8|sisyphus) ]];
then
    printf "ERROR: ALT_RELEASE missing or invalid\n"
    f_help
    exit 1
fi

# Build the image
temp_dir=$(mktemp -d)
workspace_dir="${temp_dir}/workspace"
pushd ${temp_dir} &> /dev/null

    # git clone mkimage-profile
    git clone git://git.altlinux.org/people/mike/packages/mkimage-profiles.git

    # build image
    cd mkimage-profiles

    mkdir -p "${workspace_dir}/out"

    for arch in i586 x86_64 aarch64
    do
        make \
        APTCONF="${PROGDIR}/apt/apt.conf.${ALT_RELEASE}.${arch}" \
        CLEAN=1 \
        QUIET=1 \
        NICE=1 \
        IMAGEDIR="${workspace_dir}/out" \
        ARCH="${arch}" \
        REPORT=1 \
        ve/docker.tar.xz

        mkdir -p "${workspace_dir}/${arch}"
        mv "${workspace_dir}/out/docker-${DATE}-${arch}.tar.xz" "${workspace_dir}/${arch}/alt-${ALT_RELEASE}-${arch}-${DATE}.tar.xz"
        cat > ${workspace_dir}/${arch}/Dockerfile <<EOF
FROM scratch

MAINTAINER \\
[Alexey Shabalin <shaba@altlinux.org>] \\
[Gleb Fotengauer-Malinovskiy <glebfm@altlinux.org>]

ADD alt-${ALT_RELEASE}-${arch}-${DATE}.tar.xz /

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
EOF

    done
rm -rf "${workspace_dir}/out"

popd &> /dev/null
