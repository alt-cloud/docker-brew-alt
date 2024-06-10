FROM scratch

MAINTAINER \
[Alexey Shabalin <shaba@altlinux.org>] \
[Nadezhda Fedorova  <fedor@altlinux.org]

ADD alt-p11-i586.tar.xz /

RUN true > /etc/security/limits.d/50-defaults.conf

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
