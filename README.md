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
      Run `register-qemu-aarch64` for register aarch64 in binfmt.
   4. Add non-root user for hasher.
     `hasher-useradd joe`
   5. Edit sources list for APT in apt dir.

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
$ tree /tmp/.private/joe/tmp.e3Mw8oMhta/workspace
|--aarch64
|  |--Dockerfile
|  `--alt-p8-aarch64-20180522.tar.xz
|--x86_64
|  |--Dockerfile
|  `--alt-p8-x86_64-20180522.tar.xz
|--i586
|  |--Dockerfile
|  `--alt-p8-i586-20180522.tar.xz
```

2. Force push to alt-cloud/docker-brew-alt on github in order to overwrite
   history so we aren’t storing giant piles of tarballs in git.

```
# EXAMPLE

# The value of work_dir comes from the previous output of the
# ./prep-docker-brew-branch.sh script in Step 1
$ work_dir=/tmp/.private/joe/tmp.e3Mw8oMhta/workspace

$ git checkout master

$ git branch -D p8

$ git checkout --orphan p8

$ git rm --cached -r .

$ rm -fr ./*

## Move in the files from your working dir

$ mv ${work_dir}/* .

$ git add .

$ git commit -m "Update altlinux p8 - 20180522"
[p8 (root-commit) 4c2cc8e] Update altlinux p8 - 20180522
 6 files changed, 24 insertions(+)
 create mode 100644 aarch64/Dockerfile
 create mode 100644 aarch64/alt-p8-aarch64-20180522.tar.xz
 create mode 100644 i586/Dockerfile
 create mode 100644 i586/alt-p8-i586-20180522.tar.xz
 create mode 100644 x86_64/Dockerfile
 create mode 100644 x86_64/alt-p8-x86_64-20180522.tar.xz

$ git push -f origin p8
```

3. Record commit logs of the updates
   [here](https://github.com/alt-cloud/official-images/blob/master/library/alt)

4. Send a [Pull Request](https://help.github.com/articles/using-pull-requests/)
   from
   [alt-cloud/official-images](https://github.com/alt-cloud/official-images)
   to
   [docker-library/official-images](https://github.com/docker-library/official-images/)
