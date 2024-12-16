#!/bin/bash -exu

if [ -n "${1-}" ]; then
    URL="$1"
else
    URL=http://ftp.altlinux.org/pub/distributions/ALTLinux/images
fi
IMAGE=rootfs-minimal

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

f_arches_for_branch() {
    branch=$1
    if [ "$branch" = Sisyphus ]; then
    	echo 'i586 x86_64 aarch64 riscv64'
    else
	echo 'i586 x86_64 aarch64'
    fi
}

f_branches() {
    echo Sisyphus p10 p11
}

out_dir="${temp_dir}/out"
for branch in $(f_branches); do
    rm -rf "$out_dir"
    mkdir -p "$out_dir"
    for arch in $(f_arches_for_branch "$branch"); do
        branch_lower="$(echo $branch | tr A-Z a-z)"
        echo $branch $arch $branch_lower
        mkdir -p "${out_dir}/${arch}"
        curl "$URL/$branch/cloud/$arch/alt-$branch_lower-$IMAGE-$arch.tar.xz" \
             > "$out_dir/$arch/alt-$branch_lower-$arch.tar.xz"

	case "$branch_lower" in 
		p*) lic="ALT-Container or GPLv3";;
		*) lic="GPLv3";;
	esac
        cat > ${out_dir}/${arch}/Dockerfile <<EOF
FROM scratch

MAINTAINER \\
[Alexey Shabalin <shaba@altlinux.org>] \\
[Nadezhda Fedorova <fedor@altlinux.org]

LABEL org.opencontainers.image.licenses="$lic"

ADD alt-$branch_lower-$arch.tar.xz /

RUN true > /etc/security/limits.d/50-defaults.conf

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
EOF
    done

    git branch -D "$branch_lower" &>/dev/null ||:
    export GIT_WORK_TREE="$out_dir"
    git checkout --orphan "$branch_lower"
    git rm -r .

    git add .
    git commit -m "Update ALT Linux $branch"

    git checkout master
done
