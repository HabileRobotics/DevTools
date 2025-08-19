################################################################################
#                             Dockerfile for Yocto
#
# The purpose of this dockerfile is to provide an environment to build a Yocto
# image using kas:
#     * crops/poky is the base
#     * Install pip and use it to install kas
#
# Standalone, build and run with:
#   $ docker build -t habilerobotics/humble-yocto-poky:0.0.1
#   $ docker run \
#       --rm -it --user=root \
#       -v $HOME/workspace/yocto-workdir:/workdir \
#       --workdir=/workdir \
#       habilerobotics/humble-yocto-poky:0.0.1
#
# This container may takes 20+ minutes for a clean build due to includes of
# many additional developer and Linux tools.
#
################################################################################
#
# Author:  Jose Pagan
#   Date:  07/28/2025
# Update:  07/28/2025
################################################################################

# Use crops/poky as the base image
FROM crops/poky:ubuntu-22.04

# Switch to root to install packages
USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        apt-transport-https \
        bash-completion \
        build-essential \
        black \
        build-essential \
        clang-format \
        clang-tidy \
        clangd \
        curl \
        device-tree-compiler \
        dirmngr \
        emacs \
        git \
        gnupg2 \
        gpg \
        libncurses? \
        mypy \
        nano \
        net-tools \
        nfs-client \
        python3-pip \
        python-is-python3 \
        rsync \
        ssh \
        sudo \
        tzdata \
        unzip \
        usbutils \
        wget \
        x11-apps \
        xauth \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && pip3 install --no-cache-dir --upgrade  pip \
 && pip3 install kas==4.3.2

## Prefix "docker-" to the PATH in /etc/skel/bashrc, as indicator when using a container
RUN  sed -i s/"\${debian_chroot:+(\$debian_chroot)}"/"docker-\${debian_chroot:+(\$debian_chroot)}"/g  /etc/skel/.bashrc

## This command modifies "nogroup" line, in the /etc/group file.
## We want to add "pokyuser" to that group.
RUN  sed -i '/^nogroup:/ s/$/pokyuser/' /etc/group \
  && echo "build:x:6000:pokyuser" >>  /etc/group

# Change back to the default user
USER pokyuser
