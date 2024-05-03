FROM scratch

MAINTAINER \
[Alexey Shabalin <shaba@altlinux.org>] \
[Mikhail Gordeev <obirvalger@altlinux.org]

ADD alt-p10-x86_64.tar.xz /

RUN true > /etc/security/limits.d/50-defaults.conf

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]
