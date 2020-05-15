FROM scratch

MAINTAINER \
[Alexey Shabalin <shaba@altlinux.org>] \
[Mikhail Gordeev <obirvalger@altlinux.org]

ENV container=oci
ADD alt.tar.xz /

# Labels added in support of osbs, per https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL name="ALT Base Image" \
      vendor="ALT" \
      license="GPLv2" \
      url="https://www.altlinux.org/Docker" \
      release="<release version, or sisyphus>" \
      build-date="<output of date --rfc-3339=date>"

#default CMD defined per best practices at https://github.com/docker-library/official-images/blob/master/README.md
CMD ["/bin/bash"]
