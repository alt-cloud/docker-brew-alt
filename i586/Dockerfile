FROM scratch

MAINTAINER \
[Alexey Shabalin <shaba@altlinux.org>] \
[Nadezhda Fedorova <fedor@altlinux.org>]

LABEL org.opencontainers.image.licenses="GPLv3" \
org.opencontainers.image.title="alt" \
org.opencontainers.image.description="Minimal image" \
org.opencontainers.image.vendor="ALT Linux Team"

ADD alt-sisyphus-i586.tar.xz /

RUN true > /etc/security/limits.d/50-defaults.conf

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
