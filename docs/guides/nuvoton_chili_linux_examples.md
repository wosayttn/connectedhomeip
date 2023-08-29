# Building and Running CHIP Linux Examples for NUC980/N9H30 boards

This document describes how to build below Linux examples with the NUC970/NUC980 embedded
Linux buildroot SDK and then run the output executable files on the board.

- [CHIP Linux Lighting Example](../../examples/lighting-app/linux/README.md)

This document has been tested on:

- x64 host machine to build (cross-compile) these chip examples
    1. Running Ubuntu for 64bit PC(AMD64) desktop 20.04 LTS.
- **N9H30/NUC980** board to run these chip examples
    1. Running binaries generated from buildroot Nuvoton released.

## Docker

You need these things to develop projects in the Buildroot Project environment. A host system with a minimum of 20 Gbytes of free disk space that is running a supported Linux distribution (i.e. recent releases of Fedora, CentOS, Debian, or Ubuntu), and appropriate packages installed on the system you are using for builds. Nuvoton provide two environment of building image, one is Docker and the other is Linux. Docker is a virtual machine based on host Linux OS, so the setting in the Docker will not affect the host OS and the Docker can create an environment only for building image. Linux distribution will be updated and may result in building image error, so Docker provided by Nuvoton is a better way than Linux.

Docker is an open-source project based on Linux contains. They are similar to virtual machines, but containers are more portable, more resource-friendly, and more dependent on the host operating system. Docker provides a quick and easy way to get up and running with buildroot. Install docker, Example for Ubuntu 20.04:

First, update your existing list of packages:

```bash
sudo apt-get update
```

Next, install a few prerequisite packages which let apt use packages over HTTPS:

```bash
sudo apt install apt-transport-https ca-certificates curl
```

software-properties-common
Then add Docker official GPG key for the official Docker repository to your system:

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

Use the following command to set up the stable repository, add the Docker repository to APT sources:

```bash
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
```

Next, update the package database with the Docker packages from the newly added repo:

```bash
sudo apt-get update
```

Finally, install Docker:

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io
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

## Build

### Cross-compiling toolchains and Linux kernel

Applying **Buildroot configuration file** to build related toolchain and basic demo root file system.

| Board | Buildroot configuration file |
|-|-|
| NK-RTU980(Chili) | nuvoton_nuc980_chili_matter_defconfig |
| NuMaker-HMI-N9H30 | nuvoton_n9h30_matter_defconfig |

#### For NK-RTU980

```bash
test@575f27a6d251:~/shared/buildroot$ make nuvoton_nuc980_chili_matter_defconfig
test@575f27a6d251:~/shared/buildroot$ make -j 8
```

After a coffee time, board images are outputted in folder.

```bash
test@575f27a6d251:~/shared/buildroot$ ls output/images/
Image  nuc980-chili.dtb  u-boot.bin  uImage
```

- **Image** is Linux kernel image file.
- **nuc980-chili.dtb** is Linux kernel device-tree binary file.
- **uImage** is Linux kernel image with u-boot header file.
- **u-boot.bin** is a general bootloader.

#### For NuMaker-HMI-N9H30

```bash
test@575f27a6d251:~/shared/buildroot$ make nuvoton_n9h30_matter_defconfig
test@575f27a6d251:~/shared/buildroot$ make -j 8
```

After a coffee time, board images are outputted in folder.

```bash
test@575f27a6d251:~/shared/buildroot$ ls output/images/
Image  nudesign-n9h30.dtb  u-boot.bin  uImage
```

- **Image** is Linux kernel image file.
- **nudesign-n9h30.dtb** is Linux kernel device-tree binary file.
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

test@575f27a6d251:~/shared/$ git clone <connectedhomeip's github URL> matter
test@575f27a6d251:~/shared/$ cd matter

<To clone connectedhomeip repository into matter folder>

test@575f27a6d251:~/shared/matter$ git submodule update --init
test@575f27a6d251:~/shared/matter$ source scripts/activate.sh
```

To cross-compile CHIP examples.

```bash
# lighting-app
test@575f27a6d251:~/shared/matter$ ./scripts/examples/chililinux_example.sh examples/lighting-app/linux examples/lighting-app/linux/out/armv5te
test@575f27a6d251:~/shared/matter$ arm-linux-strip -s examples/lighting-app/linux/out/armv5te/chip-lighting-app
test@575f27a6d251:~/shared/matter$ ls -al examples/lighting-app/linux/out/armv5te/chip-lighting-app

```

## Deploy

You can update matter example execution in rootfs, then rebuild **Image**.

```bash
test@575f27a6d251:~/shared/matter$ cp examples/lighting-app/linux/out/armv5te/chip-lighting-app ~/shared/buildroot/board/nuvoton/nuc980/rootfs-chili-matter/opt

test@575f27a6d251:~/shared/matter$ cd ~/shared/buildroot
test@575f27a6d251:~/shared/buildroot$ make -j 8
```

### Download NuWriter Utility

| Platform | NuWriter Utility |
|-|-|
| NUC980 | <https://github.com/OpenNuvoton/NUC980_NuWriter> |
| NUC970(N9H30) | <https://github.com/OpenNuvoton/NUC970_NuWriter> |

### Board image files

| Board | Device-tree binary file |
|-|-|
| NK-RTU980(Chili) | nuc980-chili.dtb |
| NuMaker-HMI-N9H30 | n9h30-nudesign.dtb |

### SDRAM Downloading using NuWriter

You can use **NuWriter Utility** to download **Image** and **Device-tree binary file** into SDRAM, then run it. This way is faster than deploying on SPI NOR flash for development.

- **Image(or 970image)** execution address: **0x8000**
- **Device-tree binary file** execution address: **0x1400000**
- **Option** **Download & run**

### SPI NOR flash using NuWriter

You can use **NuWriter Utility** to program images into SPI NOR flash.

- To configure booting to USB
- To select **SPI** type in NuWriter.
- To prepare **u-boot.bin**, **uImage** and **Device-tree binary file** files buildroot built.
- Save u-boot script as below into a TXT file, named **matter-uboot-env.txt**

```bash
baudrate=115200
bootdelay=1
watchdog=0
stderr=serial
stdin=serial
stdout=serial
loadkernel=sf read 0x8000 0x200000 0xB00000
loaddtb=sf read 0x1400000 0xE00000 0x8000
bootcmd=sf probe 0 30000000; run loadkernel; run loaddtb; bootm 0x8000 - 0x1400000
```

**Programming steps**

- At first, to erase all blocks.
- Program **u-boot.bin** image
  - Image Name: Specify **u-boot.bin** file path.
  - Image Type: **Loader**
  - Image execute address: **0xe00000**
  - Image start offset: **N/A**

- Program **uImage** image
  - Image Name: Specify **uImage** file path.
  - Image Type: **Data**
  - Image execute address: **N/A**
  - Image start offset: **0x200000**

- Program **Device-tree binary file** image
  - Image Name: Specify **Device-tree binary file** file path.
  - Image Type: **Data**
  - Image execute address: **N/A**
  - Image start offset: **0xe00000**

- Program **matter-uboot-env.txt** image
  - Image Name: Specify **matter-uboot-env.txt** file path.
  - Image Type: **Environment**
  - Image execute address: **N/A**
  - Image start offset: **0x80000**

- Return booting source to SPI NOR, reset board.
- Enjoy.
