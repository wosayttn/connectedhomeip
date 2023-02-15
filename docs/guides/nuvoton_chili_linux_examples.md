# Building and Running CHIP Linux Examples for NUC980 Chili board

This document describes how to build below Linux examples with the NUC980 embedded
Linux buildroot SDK and then run the output executable files on the board.

-   [CHIP Linux Lighting Example](../../examples/lighting-app/linux/README.md)

This document has been tested on:

-   x64 host machine to build (cross-compile) these chip examples
    1.  Running Ubuntu for 64bit PC(AMD64) desktop 20.04 LTS.
-   **NUC980 Chili** board to run these chip examples
    1.  Running binaries generated from buildroot Nuvoton released.

## Docker

You need these things to develop projects in the Buildroot Project environment. A host system with a minimum of 20 Gbytes of free disk space that is running a supported Linux distribution (i.e. recent releases of Fedora, CentOS, Debian, or Ubuntu), and appropriate packages installed on the system you are using for builds. Nuvoton provide two environment of building image, one is Docker and the other is Linux. Docker is a virtual machine based on host Linux OS, so the setting in the Docker will not affect the host OS and the Docker can create an environment only for building image. Linux distribution will be updated and may result in building image error, so Docker provided by Nuvoton is a better way than Linux.

Docker is an open-source project based on Linux contains. They are similar to virtual machines, but containers are more portable, more resource-friendly, and more dependent on the host operating system. Docker provides a quick and easy way to get up and running with buildroot. Install docker, Example for Ubuntu 20.04:

First, update your existing list of packages:

```bash
$ sudo apt-get update
```

Next, install a few prerequisite packages which let apt use packages over HTTPS:

```bash
$ sudo apt install apt-transport-https ca-certificates curl
```

software-properties-common
Then add Docker official GPG key for the official Docker repository to your system:

```bash
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

Use the following command to set up the stable repository, add the Docker repository to APT sources:

```bash
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
```

Next, update the package database with the Docker packages from the newly added repo:

```bash
$ sudo apt-get update
```

Finally, install Docker:

```bash
$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```

Then use the Dockerfile to generate the docker image environment. after completion, use the repo utility to download the buildroot project after enter the docker image. [Dockefile source](https://github.com/OpenNuvoton/MA35D1_Docker_Script.git) You can use the docker script we provide.

```bash
$ git clone https://github.com/OpenNuvoton/MA35D1_Docker_Script

$ ls MA35D1_Docker_Script
build.sh  Dockerfile  join.sh  README.md
```

To setup docker image and select folder to be share.

```bash
$ ./build.sh

Please enter absolute path for shared folders(eg:/home/<user name>) :
Enter docker image, you will see “[user name]@[container id]:$”

$ ./join.sh
ma35d1_test
test@575f27a6d251:~$
```

To Create a shared/buildroot folder and enter. Using git command to clone MA35D1 buildroot project in docker.
```bash
test@575f27a6d251:~$ cd shared
test@575f27a6d251:~/shared/$ git clone https://github.com/OpenNuvoton/MA35D1_Buildroot.git buildroot
```

## Building

### Cross-compiling toolchains and Linux kernel

Applying **nuvoton_nuc980_chili_matter_defconfig** to build related toolchain and basic demo root file system.
```bash
test@575f27a6d251:~/shared/buildroot$ make nuvoton_nuc980_chili_matter_defconfig
test@575f27a6d251:~/shared/buildroot$ make -j 8
```

After a coffee time, NUC980 Chili images are outputted in folder.
```bash
test@575f27a6d251:~/shared/buildroot$ ls output/images/
Image  nuc980-chili.dtb  u-boot.bin  uImage
```
- **Image** is Linux kernel image file.
- **nuc980-chili.dtb** is Linux kernel device-tree binary file.
- **uImage** is Linux kernel image with u-boot header file.
- **u-boot.bin** is a general bootloader.

**Important**

Due to python version, we need to disable python executing buildroot built.
```bash
test@575f27a6d251:~/shared/buildroot/output/host/bin$ mkdir _bk && mv python3  python3.9 _bk
```

### CHIP exampls

Install related matter dependencies packages in docker.
```bash
test@575f27a6d251:~/shared/buildroot$ sudo apt-get update
test@575f27a6d251:~/shared/buildroot$ sudo apt-get install git gcc g++ python pkg-config libssl-dev libdbus-1-dev libglib2.0-dev libavahi-client-dev ninja-build python3-venv python3-dev python3-pip unzip libgirepository1.0-dev libcairo2-dev libreadline-dev libssl-dev
```

Set cross-compiling toolchain path to PATH and update matter submodules.
```bash
test@575f27a6d251:~/shared/buildroot$ export PATH=~/shared/buildroot/output/host/bin:$PATH

test@575f27a6d251:~/shared/matter$ git submodule update --init
test@575f27a6d251:~/shared/matter$ source scripts/activate.sh
```

To cross-compile CHIP examples for NUC980 Chili.
```bash
# lighting-app
test@575f27a6d251:~/shared/matter$ ./scripts/examples/chililinux_example.sh examples/lighting-app/linux examples/lighting-app/linux/out/armv5te
test@575f27a6d251:~/shared/matter$ arm-linux-strip -s examples/lighting-app/linux/out/armv5te/chip-lighting-app
test@575f27a6d251:~/shared/matter$ ls -al examples/lighting-app/linux/out/armv5te/chip-lighting-app

# thermostat
test@575f27a6d251:~/shared/matter$ ./scripts/examples/chililinux_example.sh examples/thermostat/linux examples/thermostat/linux/out/armv5te
test@575f27a6d251:~/shared/matter$ arm-linux-strip -s examples/thermostat/linux/out/armv5te/thermostat-app
test@575f27a6d251:~/shared/matter$ ls -al examples/thermostat/linux/out/armv5te/thermostat-app

# tv-app
test@575f27a6d251:~/shared/matter$ ./scripts/examples/chililinux_example.sh examples/tv-app/linux examples/tv-app/linux/out/armv5te
test@575f27a6d251:~/shared/matter$ arm-linux-strip -s examples/tv-app/linux/out/armv5te/chip-tv-app
test@575f27a6d251:~/shared/matter$ ls -al examples/tv-app/linux/out/armv5te/chip-tv-app

# tv-casting-app
test@575f27a6d251:~/shared/matter$ ./scripts/examples/chililinux_example.sh examples/tv-casting-app/linux examples/tv-casting-app/linux/out/armv5te
test@575f27a6d251:~/shared/matter$ arm-linux-strip -s examples/tv-casting-app/linux/out/armv5te/chip-tv-casting-app
test@575f27a6d251:~/shared/matter$ ls -al examples/tv-casting-app/linux/out/armv5te/chip-tv-casting-app

# lock-app
test@575f27a6d251:~/shared/matter$ ./scripts/examples/chililinux_example.sh examples/lock-app/linux examples/lock-app/linux/out/armv5te
test@575f27a6d251:~/shared/matter$ arm-linux-strip -s examples/lock-app/linux/out/armv5te/chip-lock-app
test@575f27a6d251:~/shared/matter$ ls -al examples/lock-app/linux/out/armv5te/chip-lock-app

```

## Deploying

You can update matter example execution in rootfs, then rebuild **Image**.
```bash
test@575f27a6d251:~/shared/matter$ cp examples/lighting-app/linux/out/armv5te/chip-lighting-app ~/shared/buildroot/board/nuvoton/nuc980/rootfs-chili-matter/opt
test@575f27a6d251:~/shared/matter$ make -j 8
```

Finally, configure booting to USB and use NuWriter to download **Image** and **nuc980-chili.dtb** into DDR memory.
- Image execution address: 0x8000
- DTB execution address: 0x1400000
- Option: Download & run
