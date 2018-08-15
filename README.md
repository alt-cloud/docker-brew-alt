docker-brew-alt
==================

This project space exists as an upload entry point to import the official
[ALT Linux](https://altlinux.org) [Docker](https://www.docker.com)
Base Images built in [Hasher](https://en.altlinux.org/Hasher)
(ALT's Build System) so that they may be submitted to the
[official-images](https://github.com/docker-library/official-images) repository
for the [Docker Hub](https://hub.docker.com/).

These images are built as profile "docker" from a
[mkimage-profiles](http://nightly.altlinux.org/docs/mkimage-profiles.html)
that is part of the sub-project of BaseALT. If there
is an issue or request for a change to the contents of the ALT Docker Base
Image, please file an
[bug](https://bugzilla.altlinux.org).

Docker Base Image Build process
--------------------------------

1. Prepare build system:
   1. Install ALT Linux.
   2. Install [hasher](https://en.altlinux.org/Hasher) and [mkimage](https://en.altlinux.org/Mkimage)
     `apt-get install hasher mkimage`
   3. Install livecd-qemu-arch and qemu-user-static for cross-build for aarch64.
     `apt-get install livecd-qemu-arch qemu-user-static`
      Run (after every reboot) `register-qemu-aarch64` for register aarch64 in binfmt.
   4. Add non-root user for hasher.
     `hasher-useradd joe`

2. Run the `./prep-docker-brew-branch.sh` script as non-root user, this will build a new base image.

```
./prep-docker-brew-branch.sh p8
```

   At the end of the script you will see something similar to:

```
21:15:56 (1:31) $TMP/tmp.e3Mw8oMhta/workspace/out/docker-20180522-i586.tar.xz [24M]
** graphviz missing, target graph dot file: build/targets.dot
** diffable log: build/reports/cleanlog.log
21:17:24 (1:27) $TMP/tmp.e3Mw8oMhta/workspace/out/docker-20180522-x86_64.tar.xz [24M]
** graphviz missing, target graph dot file: build/targets.dot
** diffable log: build/reports/cleanlog.log
21:21:21 (3:56) $TMP/tmp.e3Mw8oMhta/workspace/out/docker-20180522-aarch64.tar.xz [23M]
** graphviz missing, target graph dot file: build/targets.dot
** diffable log: build/reports/cleanlog.log
```

2. Make sure that the result of the previous is correct, it should look like the
   following:

```
$ git show --stat p8
commit a3fd4f897bda9424ac515dccfc33c0a46da96a64
Author: Mikhail Gordeev <obirvalger@altlinux.org>
Date:   17 hours ago

    Update altlinux p8 - 20180814

 i586/Dockerfile                      |  10 ++++++++++
 i586/alt-p8-i586-20180814.tar.xz     | Bin 0 -> 23896040 bytes
 x86_64/Dockerfile                    |  10 ++++++++++
 x86_64/alt-p8-x86_64-20180814.tar.xz | Bin 0 -> 24017716 bytes
 4 files changed, 20 insertions(+)
```

2. Force push to alt-cloud/docker-brew-alt on github in order to overwrite
   history so we aren’t storing giant piles of tarballs in git.

```
$ git push -f origin p8
```

3. Record commit logs of the updates
   [here](https://github.com/alt-cloud/official-images/blob/master/library/alt)

4. Send a [Pull Request](https://help.github.com/articles/using-pull-requests/)
   from
   [alt-cloud/official-images](https://github.com/alt-cloud/official-images)
   to
   [docker-library/official-images](https://github.com/docker-library/official-images/)
