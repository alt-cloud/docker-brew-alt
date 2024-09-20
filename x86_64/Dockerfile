FROM scratch

MAINTAINER \
[Alexey Shabalin <shaba@altlinux.org>] \
[Nadezhda Fedorova <fedor@altlinux.org]

LABEL org.opencontainers.image.licenses="ALT-Container or GPLv3"

ADD alt-p11-x86_64.tar.xz /

RUN true > /etc/security/limits.d/50-defaults.conf

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
