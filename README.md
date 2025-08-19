# Docker image tools


This repository contains BASH scripts, Dockerfiles and artifacts to build base Docker images containing a variety of developer tools, for ROS2 projects. These scripts are intended to create _standard_ Docker images for ROS, STM32 (hardware), NXP (hardware) and Yocto development.

ROS Docker images support VSCode, ROS2 (Humble and Jazzy), colcon, DDS (fast and cyclone), ARM cross compilation, and tools for node test and debugging.

STM32 Docker image supports the STM32 CLI, IDE and JTAG debugger. This image allows for test and debug of hardware using the STLINK JTAG, via USB device.

NXP Docker image supports the MCUXpresso for VS Code. This image allows for development using the NXP tools. Configuring of hardware test and debug remains to be done.

Yocto image supports building Yoto on the desktop using KAS.

Base Docker images are build by our automation system where new base images are push to this Dockerhub repository.

A user image is a local copy of a base image with the local user credentials imprinted. The user "_create.user.image_" script pulls a base image from dockerhub, imprints the users credentials, and  stores the resulting image to the local workstation's Docker repository.


**Common themes**

Scripts provide a number of command line flags, with some flags
common to all scripts.
```
   -h ..... Help.
       Hints and flag formats are provided

   -n ..... No-Execute.
       Display Docker commands used, without executing them 

   -t ..... Type of image.
       Specifies the image to build. Valid images are:
         * humble (default) - ROS2 Humble with Ubuntu 22.04
         * jazzy - ROS2 Jazzy with Ubuntu 24.04
         * nxp   - VSCode with NXP tools, using Ubuntu 22.04
         * stm32 - VSCode with stm32 tools and ROS2 Humble
                   using Ubuntu 22.04
         * yocto - Ubuntu 22.04 with KAS

   -v ..... verbose (debug).
       Provide a copious amount of debug information
```
All scripts respond with the maximum debug information when the
DEBUG environment variable is set;
```
    DEBUG=1
 
Example:  DEBUG=1 docker.create.user.image
```

## Script Hierarchy

The scripts and the user's Dockerfile are located in the root of this repository. An image specific Dockerfile is used to define each baseline Docker images. The base "Dockerfile" descriptions are in directories suffixed by "-base" (see below). Current base images are described in "ros2-base", "nxp-base", "stm32-base", and "yocto-base".

```
    .
    ├── bitbucket-pipelines.yml
    ├── common
    ├── dds_config
    │   │── fastrtps.xml
    │   └── cyclonedds.xml
    ├── docker.build
    ├── docker.create.user.image
    ├── Dockerfile
    ├── docker.run
    ├── hub.create.image
    ├── nxp-base
    │   └── Dockerfile
    ├── README.md
    ├── ros2-base
    │   └── Dockerfile
    ├── setup.sh
    ├── stm32-base
    │   └── Dockerfile
    └── yocto-base
        └── Dockerfile
```

<u>**common**</u>

The common file contains variable and function definitions used by more than one script. This file is included by the scripts and <u>_should not be run standalone_</u>.

<u>**setup.sh**</u>

The setup script sets needed environment variables and path for this toolset. These changes apply to the local terminal and do not change your .profile or .bashrc files. You must _**<u>source</u>**_ this script in each relevant terminal window.


<u>**hub.create.image**</u>

This script creates the various baseline DevTools images. Any 
created image may "pushed" to Dockerhub after login. Baseline images contain the build-automation user "build" user and may be consumed by users to enable their desktop DevTools environment. Command line flags and arguments, specific to this script include:
```
    -c ..... Clean.
        Re-build as clean image ignoring all cached Docker
        layers. Employs Docker argument "--no-cahce"

    -p ..... Push to Dockerhub.
        After successfully building a Docker image, 
        push that image to Dockerhub.
        Note: The image will be stored on both 
              Dockerhub and the local machine.
```

<u>**docker.create.user.image**</u>

This script creates the local (user's) docker image. A user image is created from one of the Dockerhub base images. Base images ensure that code is built using a uniform set of libraries and tools for target hardware.

 
<u>**docker.run**</u>

 This script will run the local user's docker image created 
 with the "docker.create.image" script. The docker image will mount as much of user's context as possible (.ssh, .config, .emacs, .local, .bash_aliases, .vscode, etc). The image will umount the current directory (PWD) to container "/workspace" mount point.
