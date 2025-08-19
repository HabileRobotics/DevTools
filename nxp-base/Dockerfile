################################################################################
#                         Dockerfile for NXP Dev Tools
#
# This container is based on the ubuntu:22.04 (LTS) image which is built and
# maintained by Ubuntu.
#
# This Dockerfile builds several layers that include:
#  -- locale
#  -- base linux utils
#  -- NXP Tools
#
# This container takes 10+ minutes for a clean build because it includes
# numerous packages for Ubuntu and NXP.
################################################################################
#
# Author:  Jose Pagan
#   Date:  07/28/2025
# Update:  07/28/2025
################################################################################

ARG BASE_IMAGE=ubuntu:22.04
FROM $BASE_IMAGE

ARG BASE_IMAGE
ARG WORKING=workspace
ARG USERNAME=build
ARG UUID=6000
ARG GGID=6000


ARG LANGUAGE=en
ARG COUNTRY=US
ARG LOCALE=UTF-8
ARG LANG="${LANGUAGE}_${COUNTRY}.${LOCALE}"
ARG LC_ALL="${LANG}"


ENV HOME="/home/${USERNAME}"
ENV USER=${USERNAME}
ENV USERNAME=${USERNAME}

################################################################################
## [2] Set Locale: UTC-8
ENV LANG=${LANG}
ENV LC_ALL=${LC_ALL}

RUN  apt update \
  && apt install -y -q \
     	 locales \
     	 tzdata \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen ${LANGUAGE}_${COUNTRY} ${LANG} \
  && update-locale LC_ALL=${LC_ALL} LANG=${LANG} \
  && export LANG=${LANG}



###############################################################################
# [3] Basic linux applications
RUN  apt-get -y update \
  && apt-get install -y --no-install-recommends \
        autoconf \
        autoconf-archive \
        bash-completion \
        black \
        build-essential \
        bzip2 \
        catch2 \
        cmake \
        curl \
        diffutils\ 
        dnsutils \
        git \
        gpg \
        gpiod \
        iproute2 \
        iputils-ping \
        libgpiod2 \
        libdrm2 \
        libgbm1 \
        libnss3 \
        meld \
        net-tools \
        ssh \
        sudo \
        tar \
        unzip \
        usbutils \
        vim \
        wget \
        x11-apps \
        xauth \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

###############################################################################
# [4] Python
RUN  apt-get -y update \
  && apt-get install -y --no-install-recommends \
        mypy \
        python3 \
        python-is-python3 \
        python3-pip \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


###############################################################################
# [5] Linux editors
RUN  apt-get -y update \
  && apt-get install -y --no-install-recommends \
        emacs \
        nano \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*



########################################################################
## [6] To install VSCode: (or code-insiders) directly from Microsoft
#RUN  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
#  && install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg \
#  && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null \
#  && rm -f packages.microsoft.gpg \
#  && apt update \
#  && apt install code -q -y \
#  && apt-get autoremove -y \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/*



###############################################################################
# [7] NXP Required Packages


RUN  apt-get -y update \
  && apt-get install -y --no-install-recommends  pkg-config libssl-dev libdbus-1-dev libglib2.0-dev libavahi-client-dev libgirepository1.0-dev libcairo2-dev libreadline-dev python3-venv python3-dev python3-pip unzip \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# [8]
RUN  apt-get -y update \
  && apt-get install -y --no-install-recommends \
     gperf \
     ccache \
     dfu-util \
     python3-setuptools \
     python3-tk \
     python3-wheel \
     xz-utils \
     file \
     make \
     libmagic1 \
     device-tree-compiler \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


# [9]
RUN  apt-get -y update \
  && apt-get install -y --no-install-recommends \
     cmake \
     libncurses* \
     libswt-gtk* \
     libwebkitgtk-6.0-4 \
     ninja-build \
     python3-venv \
     whiptail \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*



########################################################################
## Install the NXP SDK as a layer,

## Set default arguments for SDK install
ARG FTP_SRV="controls-Precision-7920-Tower"
ARG NXP_INSTALLER_DIR="MCUXpressoInstaller"
ARG NXP_SDK_FILE_NAME="${NXP_INSTALLER_DIR}.deb"
ARG NXP_SDK_FTP_NAME="${NXP_SDK_FILE_NAME}.bin"
ARG NXP_TARGET_DIR="/tmp/NXP-software"
ARG NXP_TOOLS="mcuxpressotools"

########################################################################
## [] Installing NXP SDK tools:
## ENV LICENSE_ALREADY_ACCEPTED=Y
RUN  mkdir -p $NXP_TARGET_DIR \
  && cd $NXP_TARGET_DIR \
  && wget -q ftp://$FTP_SRV/$NXP_SDK_FTP_NAME \
  && chmod +x $NXP_SDK_FTP_NAME \
  && $NXP_TARGET_DIR/$NXP_SDK_FTP_NAME --noexec --target . \
  && EUID=$UUID  HOME=/opt/  ./install.sh \
  && rm -rf ${NXP_TARGET_DIR}

########################################################################
## [] Install the VSCode tools for NXP:
RUN  cd /opt \
  && wget -q ftp://${FTP_SRV}/${NXP_TOOLS}.tar.bz2 \
  && tar -xjf ${NXP_TOOLS}.tar.bz2 \
  && rm ${NXP_TOOLS}.tar.bz2

########################################################################
## [] Update the skeleton files in /etc/skel
##
## Prefix path with "docker-" for everyone
RUN  sed -i s/"\${debian_chroot:+(\$debian_chroot)}"/"docker-\${debian_chroot:+(\$debian_chroot)}"/g  /etc/skel/.bashrc
##
RUN  echo "[[ \${PATH/\"\${HOME}/MCUXpressoInstaller\"} == \$PATH ]] && export PATH=\${HOME}/MCUXpressoInstaller:\${PATH}"  >> /etc/skel/.bashrc
RUN  echo "[[ \${PATH/\"\${HOME}/.mcuxpressotools/cmake-3.30.0-linux-x86_64/bin\"} == \$PATH ]]  && export PATH=\${HOME}/.mcuxpressotools/cmake-3.30.0-linux-x86_64/bin:\${PATH}"  >> /etc/skel/.bashrc
  
#RUN  echo "export PATH=\${HOME}/MCUXpressoInstaller:\${PATH}"                              >> /etc/skel/.bashrc \
#  && echo "export PATH=\${HOME}/.mcuxpressotools/cmake-3.30.0-linux-x86_64/bin:\${PATH}"   >> /etc/skel/.bashrc
#  && echo "ln -s /opt/${NXP_TOOLS}  ${HOME}/${NXP_TOOLS} "                                >> /etc/skel/.bashrc \
#  && echo "ln -s /opt/${NXP_INSTALLER_DIR}  ${HOME}/${NXP_INSTALLER_DIR} "                >> /etc/skel/.bashrc

## Not needed?
RUN  ln -s /usr/bin/sudo /usr/bin/pkexec && ls /usr/bin/pk*


################################################################################
## This is needed in the personality docker file
################################################################################
# [] create build user
# and allow sudo without password
# and setup default users .bashrc
RUN mkdir -m777 -p /${WORKING}
RUN  groupadd --gid ${GGID} ${USERNAME} \
  && useradd -r -m \
       -d ${HOME} \
       -s /bin/bash \
       --uid ${UUID} \
       --gid ${GGID} \
       -c "${USERNAME}" \
       -G users,nogroup,dialout,sudo,adm \
       ${USERNAME} \
  && passwd -d ${USERNAME} \
  && cp   /etc/skel/.bash*  ${HOME} \
  && cp   /etc/skel/.profile  ${HOME} \
  && ln -s /${WORKING} ${HOME}/${WORKING} \
  && chown -R ${USERNAME}:${USERNAME} ${HOME}/.* ${HOME}/*


################################################################################
#RUN mkdir -p /run/dbus \
#    touch /run/dbus/system_bus_socket

USER ${USERNAME}

# [] Run the NXP Install
#RUN  cd $NXP_TARGET_DIR \
#  && HOME=/opt ./install.sh

########################################################################
## [] To install VSCode: (or code-insiders) directly from Microsoft
#RUN  code  --install-extension  ninja-build 
#RUN  code  --install-extension  ms-vscode.cmake-tools
#RUN  pip3 install --user -U west
